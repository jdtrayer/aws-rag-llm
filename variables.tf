variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  default     = "terraform"
}

variable "environment" {
  description = "Deployment environment (dev, qa, prod)"
  type        = string
}

variable "lambda_package_path" {
  description = "Path to zipped Lambda deployment package"
  type        = string
}
