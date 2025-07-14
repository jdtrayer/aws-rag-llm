variable "environment" {
  description = "Deployment environment (dev, qa, prod)"
  type        = string
}

variable "lambda_package_path" {
  description = "Path to zipped Lambda deployment package"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}
