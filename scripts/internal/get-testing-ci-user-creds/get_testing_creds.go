package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials/stscreds"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"log"
	"strings"
)

func getSecret(client *secretsmanager.Client, secretId string, versionStage string) string {
	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretId),
		VersionStage: aws.String(versionStage),
	}
	result, err := client.GetSecretValue(context.TODO(), input)
	if err != nil {
		log.Println(err.Error())
	}
	return *result.SecretString
}

func getAccountNumber(accounts map[string]interface{}, account string) string {
	for _, record := range accounts {
		if rec, ok := record.(map[string]interface{}); ok {
			for key, val := range rec {
				if strings.Contains(key, account) {
					account = val.(string)
				}
			}
		}
	}
	return account
}

func main() {
	// Load the Shared AWS Configuration (~/.aws/config)
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatal(err)
	}

	// Get accounts secret
	secretsmanagerClient := secretsmanager.NewFromConfig(cfg)
	environmentsSecret := getSecret(secretsmanagerClient, "environment_management", "AWSCURRENT")

	var accounts map[string]interface{}
	json.Unmarshal([]byte(environmentsSecret), &accounts)
	if err != nil {
		log.Println(err)
	}

	// Get testing-test account number
	testingTestId := getAccountNumber(accounts, "testing-test")

	// Assume role in testing-test account
	roleARN := fmt.Sprintf("arn:aws:iam::%s:role/ModernisationPlatformAccess", testingTestId)
	stsClient := sts.NewFromConfig(cfg)
	provider := stscreds.NewAssumeRoleProvider(stsClient, roleARN)
	cfg.Credentials = aws.NewCredentialsCache(provider)
	if err != nil {
		log.Fatal(err)
	}

	// Get the testing-ci credentials secret
	testingCiSecretsmanagerClient := secretsmanager.NewFromConfig(cfg)
	testingCiSecret := getSecret(testingCiSecretsmanagerClient, "testing_ci_iam_user_keys", "AWSCURRENT")

	// Print out creds
	type credentials struct {
		AWS_ACCESS_KEY_ID     string `json:"AWS_ACCESS_KEY_ID"`
		AWS_SECRET_ACCESS_KEY string `json:"AWS_SECRET_ACCESS_KEY"`
	}

	var testingCredentials credentials
	json.Unmarshal([]byte(testingCiSecret), &testingCredentials)
	if err != nil {
		log.Println(err)
	}
	fmt.Println("export AWS_ACCESS_KEY_ID=" + testingCredentials.AWS_ACCESS_KEY_ID)
	fmt.Println("export AWS_SECRET_ACCESS_KEY=" + testingCredentials.AWS_SECRET_ACCESS_KEY)
}
