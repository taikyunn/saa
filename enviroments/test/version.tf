terraform {
  required_version = ">= 1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
      configuration_aliases = [
        aws.ap-northeast-1,
      ]
    }
  }
  backend "s3" {
    bucket = "saa-test-tf-state"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
