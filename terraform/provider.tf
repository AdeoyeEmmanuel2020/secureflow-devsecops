terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.additional_tags, {
      Application = var.name_prefix
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "secureflow-devsecops"
    })
  }
}
