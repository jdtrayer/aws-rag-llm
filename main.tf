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

module "scraper" {
  source = "./modules/scraper"
  lambda_scraper_package_path = var.lambda_scraper_package_path
  s3_bucket_name = module.rag_infra.s3_bucket_name
}