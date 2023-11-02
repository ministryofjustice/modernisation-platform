package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials/stscreds"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/aws/aws-sdk-go-v2/service/securityhub"
	"github.com/aws/aws-sdk-go-v2/service/securityhub/types"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"log"
	"os"
	"strings"
)

func getSecretsManagerSecret(cfg aws.Config, secretName string) string {
	client := secretsmanager.NewFromConfig(cfg)
	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretName),
		VersionStage: aws.String("AWSCURRENT"),
	}
	result, err := client.GetSecretValue(context.TODO(), input)
	if err != nil {
		log.Print(err)
	}
	return *result.SecretString
}

func getMPAccounts(cfg aws.Config) map[string]string {
	accounts := make(map[string]string)
	// Get accounts secret
	environments := getSecretsManagerSecret(cfg, "environment_management")

	var allAccounts map[string]interface{}
	json.Unmarshal([]byte(environments), &allAccounts)

	for _, record := range allAccounts {
		if rec, ok := record.(map[string]interface{}); ok {
			for key, val := range rec {
				// if strings.Contains(key, "sprinkler-development") {
				accounts[key] = val.(string)
				// }
			}
		}
	}
	return accounts
}

func getAssumeRoleCfg(cfg aws.Config, roleARN string) aws.Config {
	newCfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Print(err)
	}
	stsClient := sts.NewFromConfig(cfg)
	provider := stscreds.NewAssumeRoleProvider(stsClient, roleARN)
	newCfg.Credentials = aws.NewCredentialsCache(provider)
	return newCfg
}

func getFindings(client *securityhub.Client, accountName string, productName string) {
	//set token for pagination
	initialToken := ""
	maxPages := 5
	pageCount := 0

	// iterate through whilst pages
	for {
		pageCount++
		// create findings input
		input := &securityhub.GetFindingsInput{
			Filters: &types.AwsSecurityFindingFilters{
				ProductName:    []types.StringFilter{{Comparison: types.StringFilterComparisonEquals, Value: aws.String(productName)}},
				RecordState:    []types.StringFilter{{Comparison: types.StringFilterComparisonEquals, Value: aws.String("ACTIVE")}},
				WorkflowStatus: []types.StringFilter{{Comparison: types.StringFilterComparisonEquals, Value: aws.String("NEW")}, {Comparison: types.StringFilterComparisonEquals, Value: aws.String("NOTIFIED")}},
				SeverityLabel:  []types.StringFilter{{Comparison: types.StringFilterComparisonEquals, Value: aws.String("CRITICAL")}, {Comparison: types.StringFilterComparisonEquals, Value: aws.String("HIGH")}},
			},
			MaxResults: aws.Int32(100),
		}

		// get findings
		response, err := client.GetFindings(context.TODO(), input)
		if err != nil {
			log.Print(err)
		}

		// open file
		file, err := os.OpenFile("findings.csv", os.O_APPEND|os.O_WRONLY, 0644)
		if err != nil {
			fmt.Println(err)
			return
		}

		// iterate through findings building string
		for _, finding := range response.Findings {

			line := ""
			if strings.Contains(*finding.ProductName, "Security Hub") {

				// Handle nil pointer if there is no url
				url := ""
				if finding.Remediation.Recommendation.Url != nil {
					url = fmt.Sprintf("%v", *finding.Remediation.Recommendation.Url)
				}

				line = fmt.Sprintf("%v|%v|%v|%v|%v|%v|%v|%v|%v",
					accountName,
					*finding.AwsAccountId,
					finding.Severity.Label,
					*finding.ProductName,
					strings.ReplaceAll(*finding.Title, "\n", ""),
					*finding.Resources[0].Id,
					strings.ReplaceAll(*finding.Description, "\n", ""),
					*finding.Remediation.Recommendation.Text,
					url,
				)
			} else {
				line = fmt.Sprintf("%v|%v|%v|%v|%v|%v|",
					accountName,
					*finding.AwsAccountId,
					finding.Severity.Label,
					*finding.ProductName,
					strings.ReplaceAll(*finding.Title, "\n", ""),
					*finding.Resources[0].Id,
				)
			}

			// write line to file
			_, err = fmt.Fprintln(file, line)
			if err != nil {
				fmt.Println(err)
				file.Close()
				return
			}
		}
		//close file
		err = file.Close()
		if err != nil {
			fmt.Println(err)
			return
		}
		// pagination iteration
		if response.NextToken != nil && pageCount < 10 {
			initialToken = *response.NextToken
		} else {
			initialToken = ""
		}
		if initialToken == "" {
			if pageCount >= maxPages {
				log.Printf("Account %s has more than %d pages of results for %s, see AWS console", accountName, maxPages, productName)
			}
			break
		}
	}
}

func main() {
	// Load the Shared AWS Configuration (~/.aws/config)
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Print(err)
	}

	// Get MP accounts
	accounts := getMPAccounts(cfg)

	// Create file
	file, err := os.Create("findings.csv")
	if err != nil {
		log.Print(err)
		file.Close()
	}
	// write headings to file
	_, err = fmt.Fprintln(file, "Account Name|Account ID|Severity|Product Name|Title|Affected Resources|Description|Remediation|Remediation URL")
	if err != nil {
		fmt.Println(err)
		file.Close()
		return
	}

	// Services to get findings for
	var services = []string{
		"Security Hub",
		"Config",
		"Inspector",
		"GuardDuty",
		"Firewall Manager",
		"Health",
		"IAM Access Analyzer",
		"Trusted Advisor",
		"Macie",
		"Systems Manager Patch Manager",
	}

	// Iterate through accounts
	for accountName, accountId := range accounts {
		log.Printf("Account: %s: %s", accountName, accountId)
		// Get config for account
		accountCfg := getAssumeRoleCfg(cfg, fmt.Sprintf("arn:aws:iam::%s:role/ModernisationPlatformAccess", accountId))
		// Create client
		client := securityhub.NewFromConfig(accountCfg)
		// Get security hub findings
		for _, service := range services {
			getFindings(client, accountName, service)
		}
	}
}
