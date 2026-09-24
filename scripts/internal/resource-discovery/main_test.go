package main

import (
	"context"
	"errors"
	"io"
	"reflect"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/configservice"
)

type fakeConfigClient struct {
	pages      []*configservice.SelectResourceConfigOutput
	err        error
	calls      int
	nextTokens []*string
}

func (client *fakeConfigClient) SelectResourceConfig(_ context.Context, input *configservice.SelectResourceConfigInput, _ ...func(*configservice.Options)) (*configservice.SelectResourceConfigOutput, error) {
	client.nextTokens = append(client.nextTokens, input.NextToken)
	if client.err != nil {
		return nil, client.err
	}
	page := client.pages[client.calls]
	client.calls++
	return page, nil
}

func TestParseOptions(t *testing.T) {
	t.Setenv("ACCOUNT_NAME", "account-from-environment")

	opts, err := parseOptions([]string{
		"--account-name", "example-development",
		"--regions", "eu-west-2, us-east-1,eu-west-2",
		"--resource-type", "AWS::RDS::DBInstance",
	}, io.Discard)
	if err != nil {
		t.Fatalf("parseOptions() error = %v", err)
	}

	want := options{
		accountName:  "example-development",
		regions:      []string{"eu-west-2", "us-east-1"},
		resourceType: "AWS::RDS::DBInstance",
	}
	if !reflect.DeepEqual(opts, want) {
		t.Fatalf("parseOptions() = %#v, want %#v", opts, want)
	}
}

func TestParseOptionsRequiresAccountName(t *testing.T) {
	t.Setenv("ACCOUNT_NAME", "")
	t.Setenv("TF_WORKSPACE", "")

	_, err := parseOptions(nil, io.Discard)
	if err == nil || !strings.Contains(err.Error(), "account name is required") {
		t.Fatalf("parseOptions() error = %v, want account name error", err)
	}
}

func TestParseOptionsRequiresRegion(t *testing.T) {
	t.Setenv("ACCOUNT_NAME", "example-development")

	_, err := parseOptions([]string{"--regions", ", ,"}, io.Discard)
	if err == nil || !strings.Contains(err.Error(), "at least one AWS Config region is required") {
		t.Fatalf("parseOptions() error = %v, want region error", err)
	}
}

func TestDiscoverAccount(t *testing.T) {
	euWest2 := &fakeConfigClient{
		pages: []*configservice.SelectResourceConfigOutput{
			{
				Results: []string{
					`{"accountId":"123456789012","awsRegion":"eu-west-2","arn":"arn:aws:ec2:eu-west-2:123456789012:vpc/vpc-123","resourceId":"vpc-123","resourceName":"application-vpc","resourceType":"AWS::EC2::VPC"}`,
					`{"accountId":"123456789012","awsRegion":"eu-west-2","arn":"arn:aws:ec2:eu-west-2:123456789012:instance/i-123","resourceId":"i-123","resourceName":"application-server","resourceType":"AWS::EC2::Instance"}`,
					`{"accountId":"123456789012","awsRegion":"eu-west-2","arn":"arn:aws:iam::123456789012:role/application-role","resourceId":"ARO123","resourceName":"application-role","resourceType":"AWS::IAM::Role"}`,
				},
				NextToken: aws.String("next-page"),
			},
			{
				Results: []string{
					`{"accountId":"123456789012","awsRegion":"eu-west-2","arn":"arn:aws:rds:eu-west-2:123456789012:db:application-db","resourceId":"application-db","resourceName":"application-db","resourceType":"AWS::RDS::DBInstance"}`,
				},
			},
		},
	}
	usEast1 := &fakeConfigClient{
		pages: []*configservice.SelectResourceConfigOutput{
			{
				Results: []string{
					`{"accountId":"123456789012","awsRegion":"us-east-1","arn":"arn:aws:iam::123456789012:role/application-role","resourceId":"ARO123","resourceName":"application-role","resourceType":"AWS::IAM::Role"}`,
					`{"accountId":"123456789012","awsRegion":"us-east-1","arn":"arn:aws:s3:::application-bucket","resourceId":"application-bucket","resourceName":"application-bucket","resourceType":"AWS::S3::Bucket"}`,
					`{"accountId":"123456789012","awsRegion":"us-east-1","arn":"arn:aws:cloudfront::123456789012:distribution/ABC123","resourceId":"ABC123","resourceName":"distribution","resourceType":"AWS::CloudFront::Distribution"}`,
				},
			},
		},
	}
	clients := map[string]configAPI{
		"eu-west-2": euWest2,
		"us-east-1": usEast1,
	}
	opts := options{
		accountName:  "example-development",
		regions:      []string{"eu-west-2", "us-east-1"},
		resourceType: allResourceTypes,
	}

	got, err := discoverAccount(context.Background(), func(region string) configAPI {
		return clients[region]
	}, opts)
	if err != nil {
		t.Fatalf("discoverAccount() error = %v", err)
	}

	want := []resource{
		{
			AccountName:  "example-development",
			AccountID:    "123456789012",
			Region:       "eu-west-2",
			ResourceType: "AWS::EC2::Instance",
			Identifier:   "i-123",
			Name:         "application-server",
			ARN:          "arn:aws:ec2:eu-west-2:123456789012:instance/i-123",
		},
		{
			AccountName:  "example-development",
			AccountID:    "123456789012",
			Region:       "eu-west-2",
			ResourceType: "AWS::IAM::Role",
			Identifier:   "ARO123",
			Name:         "application-role",
			ARN:          "arn:aws:iam::123456789012:role/application-role",
		},
		{
			AccountName:  "example-development",
			AccountID:    "123456789012",
			Region:       "eu-west-2",
			ResourceType: "AWS::RDS::DBInstance",
			Identifier:   "application-db",
			Name:         "application-db",
			ARN:          "arn:aws:rds:eu-west-2:123456789012:db:application-db",
		},
		{
			AccountName:  "example-development",
			AccountID:    "123456789012",
			Region:       "us-east-1",
			ResourceType: "AWS::S3::Bucket",
			Identifier:   "application-bucket",
			Name:         "application-bucket",
			ARN:          "arn:aws:s3:::application-bucket",
		},
	}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("discoverAccount() = %#v, want %#v", got, want)
	}
	if euWest2.calls != 2 {
		t.Fatalf("SelectResourceConfig calls in eu-west-2 = %d, want 2", euWest2.calls)
	}
	if euWest2.nextTokens[0] != nil || aws.ToString(euWest2.nextTokens[1]) != "next-page" {
		t.Fatalf("SelectResourceConfig tokens = %#v, want nil then next-page", euWest2.nextTokens)
	}
}

func TestDiscoverAccountFiltersResourceType(t *testing.T) {
	client := &fakeConfigClient{
		pages: []*configservice.SelectResourceConfigOutput{
			{
				Results: []string{
					`{"accountId":"123456789012","awsRegion":"eu-west-2","arn":"arn:aws:ec2:eu-west-2:123456789012:instance/i-123","resourceId":"i-123","resourceType":"AWS::EC2::Instance"}`,
					`{"accountId":"123456789012","awsRegion":"eu-west-2","arn":"arn:aws:rds:eu-west-2:123456789012:db:application-db","resourceId":"application-db","resourceType":"AWS::RDS::DBInstance"}`,
				},
			},
		},
	}
	opts := options{
		accountName:  "example-development",
		regions:      []string{"eu-west-2"},
		resourceType: "aws::rds::dbinstance",
	}

	got, err := discoverAccount(context.Background(), func(string) configAPI { return client }, opts)
	if err != nil {
		t.Fatalf("discoverAccount() error = %v", err)
	}
	if len(got) != 1 || got[0].ResourceType != "AWS::RDS::DBInstance" {
		t.Fatalf("discoverAccount() = %#v, want one RDS DB instance", got)
	}
}

func TestDiscoverAccountReturnsQueryError(t *testing.T) {
	client := &fakeConfigClient{err: errors.New("access denied")}
	opts := options{
		accountName:  "example-development",
		regions:      []string{"eu-west-2"},
		resourceType: allResourceTypes,
	}

	_, err := discoverAccount(context.Background(), func(string) configAPI { return client }, opts)
	if err == nil || !strings.Contains(err.Error(), "query AWS Config in eu-west-2: access denied") {
		t.Fatalf("discoverAccount() error = %v, want contextual Config query error", err)
	}
}

func TestDiscoverRegionReturnsInvalidResultError(t *testing.T) {
	client := &fakeConfigClient{
		pages: []*configservice.SelectResourceConfigOutput{{Results: []string{"not-json"}}},
	}

	_, err := discoverRegion(context.Background(), client, "example-development", "eu-west-2")
	if err == nil || !strings.Contains(err.Error(), "decode AWS Config result in eu-west-2") {
		t.Fatalf("discoverRegion() error = %v, want contextual decode error", err)
	}
}
