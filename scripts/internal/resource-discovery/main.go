package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"sort"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/configservice"
)

const (
	allResourceTypes    = "all"
	inventoryExpression = "SELECT accountId, awsRegion, arn, resourceId, resourceName, resourceType"
)

var defaultRegions = []string{
	"eu-central-1",
	"eu-west-1",
	"eu-west-2",
	"eu-west-3",
	"us-east-1",
}

type options struct {
	accountName  string
	regions      []string
	resourceType string
}

type resource struct {
	AccountName  string `json:"account_name"`
	AccountID    string `json:"account_id"`
	Region       string `json:"region"`
	ResourceType string `json:"resource_type"`
	Identifier   string `json:"identifier"`
	Name         string `json:"name,omitempty"`
	ARN          string `json:"arn"`
}

type configAPI interface {
	SelectResourceConfig(context.Context, *configservice.SelectResourceConfigInput, ...func(*configservice.Options)) (*configservice.SelectResourceConfigOutput, error)
}

type configClientFactory func(region string) configAPI

type configQueryResult struct {
	AccountID    string `json:"accountId"`
	AWSRegion    string `json:"awsRegion"`
	ARN          string `json:"arn"`
	ResourceID   string `json:"resourceId"`
	ResourceName string `json:"resourceName"`
	ResourceType string `json:"resourceType"`
}

func main() {
	if err := run(context.Background(), os.Args[1:], os.Stdout, os.Stderr); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(ctx context.Context, args []string, output io.Writer, errorOutput io.Writer) error {
	opts, err := parseOptions(args, errorOutput)
	if err != nil {
		return err
	}

	awsConfig, err := awsconfig.LoadDefaultConfig(ctx)
	if err != nil {
		return fmt.Errorf("load AWS configuration: %w", err)
	}

	clientFactory := func(region string) configAPI {
		regionConfig := awsConfig
		regionConfig.Region = region
		return configservice.NewFromConfig(regionConfig)
	}

	resources, err := discoverAccount(ctx, clientFactory, opts)
	if err != nil {
		return err
	}

	encoder := json.NewEncoder(output)
	encoder.SetEscapeHTML(false)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(resources); err != nil {
		return fmt.Errorf("encode discovery results: %w", err)
	}

	return nil
}

func parseOptions(args []string, errorOutput io.Writer) (options, error) {
	var opts options
	var regionList string
	flags := flag.NewFlagSet("resource-discovery", flag.ContinueOnError)
	flags.SetOutput(errorOutput)
	flags.StringVar(&opts.accountName, "account-name", firstNonEmpty(os.Getenv("ACCOUNT_NAME"), os.Getenv("TF_WORKSPACE")), "name of the AWS account being queried")
	flags.StringVar(&regionList, "regions", strings.Join(defaultRegions, ","), "comma-separated AWS Config regions to query")
	flags.StringVar(&opts.resourceType, "resource-type", allResourceTypes, "AWS Config resource type to discover, or all")

	if err := flags.Parse(args); err != nil {
		return options{}, err
	}
	if flags.NArg() != 0 {
		return options{}, fmt.Errorf("unexpected positional arguments: %s", strings.Join(flags.Args(), " "))
	}

	opts.accountName = strings.TrimSpace(opts.accountName)
	opts.resourceType = strings.TrimSpace(opts.resourceType)

	if opts.accountName == "" {
		return options{}, errors.New("account name is required; use --account-name or set ACCOUNT_NAME")
	}
	if opts.resourceType == "" {
		return options{}, errors.New("resource type cannot be empty")
	}
	if strings.EqualFold(opts.resourceType, allResourceTypes) {
		opts.resourceType = allResourceTypes
	}

	regions, err := parseRegions(regionList)
	if err != nil {
		return options{}, err
	}
	opts.regions = regions

	return opts, nil
}

func discoverAccount(ctx context.Context, clientFactory configClientFactory, opts options) ([]resource, error) {
	resources := make([]resource, 0)
	seen := make(map[string]struct{})

	for _, region := range opts.regions {
		regionResources, err := discoverRegion(ctx, clientFactory(region), opts.accountName, region)
		if err != nil {
			return nil, err
		}

		for _, discoveredResource := range regionResources {
			if isNetworkResourceType(discoveredResource.ResourceType) {
				continue
			}
			if opts.resourceType != allResourceTypes && !strings.EqualFold(discoveredResource.ResourceType, opts.resourceType) {
				continue
			}

			key := resourceKey(discoveredResource)
			if _, found := seen[key]; found {
				continue
			}
			seen[key] = struct{}{}
			resources = append(resources, discoveredResource)
		}
	}

	sort.Slice(resources, func(first, second int) bool {
		if resources[first].ResourceType != resources[second].ResourceType {
			return resources[first].ResourceType < resources[second].ResourceType
		}
		if resources[first].Region != resources[second].Region {
			return resources[first].Region < resources[second].Region
		}
		return resources[first].Identifier < resources[second].Identifier
	})

	return resources, nil
}

func discoverRegion(ctx context.Context, client configAPI, accountName string, queryRegion string) ([]resource, error) {
	resources := make([]resource, 0)
	paginator := configservice.NewSelectResourceConfigPaginator(client, &configservice.SelectResourceConfigInput{
		Expression: aws.String(inventoryExpression),
		Limit:      100,
	})

	for paginator.HasMorePages() {
		page, err := paginator.NextPage(ctx)
		if err != nil {
			return nil, fmt.Errorf("query AWS Config in %s: %w", queryRegion, err)
		}

		for _, result := range page.Results {
			var configResource configQueryResult
			if err := json.Unmarshal([]byte(result), &configResource); err != nil {
				return nil, fmt.Errorf("decode AWS Config result in %s: %w", queryRegion, err)
			}
			if configResource.ResourceType == "" || configResource.ResourceID == "" {
				return nil, fmt.Errorf("AWS Config result in %s is missing resourceType or resourceId", queryRegion)
			}

			resourceRegion := configResource.AWSRegion
			if resourceRegion == "" {
				resourceRegion = queryRegion
			}

			resources = append(resources, resource{
				AccountName:  accountName,
				AccountID:    configResource.AccountID,
				Region:       resourceRegion,
				ResourceType: configResource.ResourceType,
				Identifier:   configResource.ResourceID,
				Name:         configResource.ResourceName,
				ARN:          configResource.ARN,
			})
		}
	}

	return resources, nil
}

func parseRegions(value string) ([]string, error) {
	regions := make([]string, 0)
	seen := make(map[string]struct{})
	for _, item := range strings.Split(value, ",") {
		region := strings.TrimSpace(item)
		if region == "" {
			continue
		}
		if _, found := seen[region]; found {
			continue
		}
		seen[region] = struct{}{}
		regions = append(regions, region)
	}

	if len(regions) == 0 {
		return nil, errors.New("at least one AWS Config region is required")
	}

	return regions, nil
}

func resourceKey(discoveredResource resource) string {
	if discoveredResource.ARN != "" {
		return discoveredResource.ARN
	}
	return strings.Join([]string{
		discoveredResource.AccountID,
		discoveredResource.Region,
		discoveredResource.ResourceType,
		discoveredResource.Identifier,
	}, "|")
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if value != "" {
			return value
		}
	}
	return ""
}
