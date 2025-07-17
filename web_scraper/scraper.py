import json
import requests
import boto3
from urllib.parse import urlparse

s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        url = event.get("url")
        if not url:
            return {
                "statusCode": 400,
                "body": "Missing 'url' in request"
            }

        response = requests.get(url)
        response.raise_for_status()

        domain = urlparse(url).netloc.replace('.', '_')
        key = f"scraped/{domain}.html"

        s3.put_object(
            Bucket="rag-dev-docs-ae9e1055",
            Key=key,
            Body=response.text,
            ContentType='text/html'
        )

        return {
            "statusCode": 200,
            "body": f"Content from {url} stored at {key}"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": str(e)
        }
