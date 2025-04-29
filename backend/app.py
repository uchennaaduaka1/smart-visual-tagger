import json
import boto3
import time
import traceback

dynamodb = boto3.resource('dynamodb')
rekognition = boto3.client('rekognition')

def lambda_handler(event, context):
    print("Incoming Event:", json.dumps(event))

    try:
        record = event['Records'][0]['s3']
        bucket = record['bucket']['name']
        key = record['object']['key']

        table_name = "ImageLabels"
        table = dynamodb.Table(table_name)

        max_retries = 3
        retry_delay = 1

        for attempt in range(max_retries):
            try:
                response = rekognition.detect_labels(
                    Image={'S3Object': {'Bucket': bucket, 'Name': key}},
                    MaxLabels=10,
                    MinConfidence=75
                )
                labels = [label['Name'] for label in response['Labels']]
                print(f"Labels for {key}: {labels}")

                # Save to DynamoDB
                table.put_item(
                    Item={
                        'image': key,
                        'labels': labels
                    }
                )

                return {
                    'statusCode': 200,
                    'body': json.dumps({'image': key, 'labels': labels})
                }

            except rekognition.exceptions.InvalidS3ObjectException as e:
                print(f"[Attempt {attempt + 1}] Rekognition not ready yet: {e}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay * (2 ** attempt))
                else:
                    raise

    except Exception as e:
        print(f"Final Error processing image: {str(e)}")
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
