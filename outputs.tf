output "query_api_url" {
  description = "RAG API URL from module"
  value       = module.rag_infra.query_api_url
}

output "query_key" {
  description = "API Key from the RAG module"
  value       = module.rag_infra.api_key_value
  sensitive   = true
}
