terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.36.0"
    }
  }
}
provider "aws" {
  region = "us-west-2"  # Update with your desired region
}

