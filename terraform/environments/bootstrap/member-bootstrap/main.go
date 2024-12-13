package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
)

type PagerDutyEvent struct {
	RoutingKey  string           `json:"routing_key"`
	EventAction string           `json:"event_action"`
	Payload     PagerDutyPayload `json:"payload"`
}

type PagerDutyPayload struct {
	Summary       string                 `json:"summary"`
	Source        string                 `json:"source"`
	Severity      string                 `json:"severity"`
	CustomDetails map[string]interface{} `json:"custom_details"`
}

func getAccountAlias(sess *session.Session) (string, error) {
	svc := iam.New(sess)
	result, err := svc.ListAccountAliases(&iam.ListAccountAliasesInput{})
	if err != nil {
		return "", err
	}
	if len(result.AccountAliases) > 0 {
		return aws.StringValue(result.AccountAliases[0]), nil
	}
	return "NoAlias", nil
}

func sendToPagerDuty(event PagerDutyEvent) error {
	payloadBytes, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("error marshaling PagerDuty event: %w", err)
	}

	req, err := http.NewRequest("POST", "https://events.pagerduty.com/v2/enqueue", bytes.NewBuffer(payloadBytes))
	if err != nil {
		return fmt.Errorf("error creating HTTP request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("error sending request to PagerDuty: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("error from PagerDuty API: %s", resp.Status)
	}

	log.Printf("Successfully sent alert to PagerDuty: %s", resp.Status)
	return nil
}

func handler(ctx context.Context, snsEvent events.SNSEvent) error {
	// AWS session for fetching account alias
	sess := session.Must(session.NewSession())
	accountAlias, err := getAccountAlias(sess)
	if err != nil {
		log.Printf("Failed to retrieve account alias: %v", err)
		accountAlias = "Unknown"
	}

	// Loop through records in the SNS event
	for _, record := range snsEvent.Records {
		snsMessage := record.SNS.Message
		log.Printf("Processing SNS message: %s", snsMessage)

		// Parse the SNS message to extract alarm details (JSON expected)
		var alarmDetails map[string]interface{}
		if err := json.Unmarshal([]byte(snsMessage), &alarmDetails); err != nil {
			log.Printf("Failed to parse SNS message: %v", err)
			continue
		}

		// Extract relevant fields (modify as needed for your SNS payload)
		alarmName := alarmDetails["AlarmName"].(string)
		accountID := alarmDetails["AWSAccountId"].(string)
		alarmArn := alarmDetails["AlarmArn"].(string)
		alarmDescription := alarmDetails["AlarmDescription"].(string)
		newStateReason := alarmDetails["NewStateReason"].(string)
		newStateValue := alarmDetails["NewStateValue"].(string)
		stateChangeTime := alarmDetails["StateChangeTime"].(string)
		// Construct custom details
		customDetails := map[string]interface{}{
			"Account Name":      accountAlias,
			"AWS Account Id":    accountID,
			"Alarm Name":        alarmName,
			"Alarm Arn":         alarmArn,
			"Alarm Description": alarmDescription,
			"New State Reason":  newStateReason,
			"New State Value":   newStateValue,
			"State Change Time": stateChangeTime,
		}

		// Construct PagerDuty event
		pagerDutyEvent := PagerDutyEvent{
			RoutingKey:  os.Getenv("PAGERDUTY_INTEGRATION_KEY"), // Set in Lambda environment variables
			EventAction: "trigger",
			Payload: PagerDutyPayload{
				Summary:       fmt.Sprintf(":rotating_light: **Alarm Triggered:** %s\n**AWS Account:** %s (%s)", alarmName, accountAlias, accountID),
				Source:        fmt.Sprintf("AWS Account: %s (%s)", accountAlias, accountID),
				Severity:      "critical",
				CustomDetails: customDetails,
			},
		}

		// Send the enriched alert to PagerDuty with retry and backoff
		retries := 3
		for i := 0; i < retries; i++ {
			err := sendToPagerDuty(pagerDutyEvent)
			if err != nil {
				if i < retries-1 {
					log.Printf("Retrying to send alert to PagerDuty: attempt %d", i+2)
					time.Sleep(time.Duration(i+1) * time.Second) // Exponential backoff
					continue
				}
				log.Printf("Failed to send alert to PagerDuty after %d attempts: %v", retries, err)
			} else {
				break
			}
		}
	}

	return nil
}

func main() {
	lambda.Start(handler)
}
