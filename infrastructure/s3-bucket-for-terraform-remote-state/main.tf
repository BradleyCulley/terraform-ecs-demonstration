# note: this must be run manually from a local machine or a pipeline, once,
# to bootstrap Terraform remote state being stored in an S3 bucket
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type = string
}

resource "aws_s3_bucket" "bucket" {
  bucket = "remote-state-bucket-for-terraform-ecs-demonstration"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
