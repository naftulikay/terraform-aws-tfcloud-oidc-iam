# tfcloud-oidc-iam Module - Terraform Provider Configuration

terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tls = {
        source = "hashicorp/tls"
    }
  }
}