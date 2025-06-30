import base64
import json
import datetime

def lambda_handler(event, context):
    output = []

    for record in event['records']:
        try:
            # Decode the base64-encoded log record
            payload = base64.b64decode(record['data']).decode('utf-8')
            log_event = json.loads(payload)

            # Extract the account ID (WAF logs include this as 'owner')
            account_id = log_event.get('owner', 'unknown')

            # Use event timestamp or fallback to now
            timestamp = log_event.get('timestamp')
            if timestamp:
                dt = datetime.datetime.utcfromtimestamp(int(timestamp) / 1000)
            else:
                dt = datetime.datetime.utcnow()

            # Set the dynamic prefix
            prefix = f"AWSLogs/{account_id}/waflogs/{dt.year:04}/{dt.month:02}/{dt.day:02}/"

            output_record = {
                'recordId': record['recordId'],
                'result': 'Ok',
                'data': record['data'],
                'metadata': {
                    'dynamicPartitionMetadata': {
                        'S3Prefix': prefix
                    }
                }
            }

        except Exception as e:
            # Drop on failure
            output_record = {
                'recordId': record['recordId'],
                'result': 'Dropped',
                'data': record['data']
            }

        output.append(output_record)

    return {'records': output}

