output "query_api_url" {
  description = "URL to call the RAG query endpoint"
  value       = "https://${aws_api_gateway_rest_api.rag_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod/query"
}

output "api_key_value" {
  description = "API Key for accessing the RAG API Gateway"
  value       = aws_api_gateway_api_key.api_key.value
  sensitive   = true
}

output "s3_bucket_name" {
  description = "the s3 bucket name"
  value = aws_s3_bucket.docs.bucket
}

output "knowledge_base_arn" {
  value = aws_bedrockknowledge_knowledge_base.rag_kb.arn
}
