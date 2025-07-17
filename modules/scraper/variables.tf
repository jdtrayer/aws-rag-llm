variable "lambda_scraper_package_path" {
  description = "Path to the ZIP file for the scraper Lambda"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store scraped content"
  type        = string
}
