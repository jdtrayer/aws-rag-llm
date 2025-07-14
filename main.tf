terraform {
  backend "s3" {
    # These values will be overridden per workspace/env
    bucket = "jdtrayer-my-terraform-state-bucket"
    key    = "rag-bedrock/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "rag_infra" {
  source      = "./modules/rag"
  environment = var.environment
  lambda_package_path = var.lambda_package_path
  aws_region         = var.aws_region
}
