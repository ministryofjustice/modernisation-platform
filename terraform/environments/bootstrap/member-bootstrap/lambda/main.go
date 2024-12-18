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
	"github.com/aws/aws-sdk-go/service/cloudtrail"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
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

func searchCloudTrailLogs(sess *session.Session, alarmArn string, stateChangeTime string) (string, error) {
	ct := cloudtrail.New(sess)

	// Define the custom time layout
	const customTimeLayout = "2006-01-02T15:04:05.000-0700"

	// Parse the state change time using the custom layout
	eventTime, err := time.Parse(customTimeLayout, stateChangeTime)
	if err != nil {
		return "", fmt.Errorf("failed to parse state change time: %v", err)
	}

	// Define the time range for the CloudTrail query
	startTime := eventTime.Add(-5 * time.Minute)
	endTime := eventTime.Add(5 * time.Minute)

	// Get the metric filter details
	metricFilter, err := getMetricFilter(sess, alarmArn)
	if err != nil {
		return "", fmt.Errorf("failed to get metric filter: %v", err)
	}

	// Query CloudTrail logs using the metric filter pattern
	input := &cloudtrail.LookupEventsInput{
		StartTime: aws.Time(startTime),
		EndTime:   aws.Time(endTime),
		LookupAttributes: []*cloudtrail.LookupAttribute{
			{
				AttributeKey:   aws.String(cloudtrail.LookupAttributeKeyEventName),
				AttributeValue: aws.String(*metricFilter.FilterPattern),
			},
		},
	}

	result, err := ct.LookupEvents(input)
	if err != nil {
		return "", fmt.Errorf("failed to lookup CloudTrail events: %v", err)
	}

	// Extract the user identity from the CloudTrail logs
	for _, event := range result.Events {
		var eventData map[string]interface{}
		if err := json.Unmarshal([]byte(*event.CloudTrailEvent), &eventData); err != nil {
			log.Printf("Failed to parse CloudTrail event: %v", err)
			continue
		}

		if userIdentity, ok := eventData["userIdentity"].(map[string]interface{}); ok {
			if userName, ok := userIdentity["userName"].(string); ok {
				return userName, nil
			}
		}
	}

	return "Unknown", nil
}

func getMetricFilter(sess *session.Session, alarmArn string) (*cloudwatchlogs.MetricFilter, error) {
	cw := cloudwatch.New(sess)

	// Get Alarm Details
	alarmDetails, err := cw.DescribeAlarms(&cloudwatch.DescribeAlarmsInput{
		AlarmNames: []*string{aws.String(alarmArn)},
	})
	if err != nil {
		return nil, fmt.Errorf("failed to describe alarm: %v", err)
	}
	if len(alarmDetails.MetricAlarms) == 0 {
		return nil, fmt.Errorf("alarm %s not found", alarmArn)
	}

	// Extract Metric Filter Name
	alarm := alarmDetails.MetricAlarms[0]
	logGroupName := aws.StringValue(alarm.Dimensions[0].Value) // Assumes log group is in first dimension; adjust if needed

	cwLogs := cloudwatchlogs.New(sess)
	filters, err := cwLogs.DescribeMetricFilters(&cloudwatchlogs.DescribeMetricFiltersInput{
		LogGroupName: aws.String(logGroupName),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to describe metric filters: %v", err)
	}
	if len(filters.MetricFilters) == 0 {
		return nil, fmt.Errorf("no metric filters found for log group: %s", logGroupName)
	}

	return filters.MetricFilters[0], nil
}

func handler(ctx context.Context, snsEvent events.SNSEvent) error {
	// AWS session for fetching account alias and CloudTrail logs
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

		// Search CloudTrail logs to find the user identity
		userIdentity, err := searchCloudTrailLogs(sess, alarmArn, stateChangeTime)
		if err != nil {
			log.Printf("Failed to search CloudTrail logs: %v", err)
			userIdentity = "Unknown"
		}

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
			"User Identity":     userIdentity,
		}

		// Construct PagerDuty event
		pagerDutyEvent := PagerDutyEvent{
			RoutingKey:  os.Getenv("PAGERDUTY_INTEGRATION_KEY"), // Set in Lambda environment variables
			EventAction: "trigger",
			Payload: PagerDutyPayload{
				Summary:       fmt.Sprintf("Alarm Triggered: %s AWS Account: %s (%s)", alarmName, accountAlias, accountID),
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
