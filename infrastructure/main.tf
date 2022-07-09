terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "remote-state-bucket-for-terraform-ecs-demonstration"
    key    = "terraform-remote-state-key"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}


variable "image_tag" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "aws_region" {
  type = string
}

#module "s3" {
#  source      = "./s3"
#  bucket_name = "demo-application-s3-bucket"
#}

module "ecr_frontend" {
  source = "./ecr"

  image_name = "demo-application-frontend"
}

module "ecr_backend" {
  source = "./ecr"

  image_name = "demo-application-backend"
}

module "route_53" {
  source = "./route-53"

  frontend_alb_dns_name = module.ecs.frontend_alb_dns_name

  backend_alb_dns_name = module.ecs.backend_alb_dns_name

  alb_zone_id = module.ecs.alb_zone_id

  domain_name = "terraform-demo-project.com"
}

module "ecs" {
  source = "./ecs-cluster"

  frontend_repository_url = module.ecr_frontend.repository_url

  backend_repository_url = module.ecr_backend.repository_url

  acm_certificate_arn = module.route_53.acm_certificate_arn

  image_tag = var.image_tag

  aws_access_key_id = var.aws_access_key_id

  aws_secret_access_key = var.aws_secret_access_key

  aws_region = var.aws_region
}
