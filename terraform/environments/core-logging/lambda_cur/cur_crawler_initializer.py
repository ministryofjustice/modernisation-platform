
#!/usr/bin/env python
import os
import boto3

def lambda_handler(event, context):
    """Main function"""
    glue_client = boto3.client('glue')
    try:
        response = glue_client.start_crawler(
            Name=os.environ['CRAWLER_NAME']
        )
        print('Successfully triggered crawler')
    except glue_client.exceptions.CrawlerRunningException as err:
        print('Crawler already running; ignoring trigger.')
        return err.response['Error']['Message']
