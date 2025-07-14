import json

def lambda_handler(event, context):
    # Extract query parameters
    query = event.get("queryStringParameters", {}).get("q", "Hello!")

    # Simulate RAG response
    response = {
        "query": query,
        "answer": f"You asked: '{query}'. Here's a dummy answer from RAG."
    }

    return {
        "statusCode": 200,
        "headers": { "Content-Type": "application/json" },
        "body": json.dumps(response)
    }
