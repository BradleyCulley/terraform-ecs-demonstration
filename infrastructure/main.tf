variable "image_tag" {
  type = string
}

variable "google_recaptcha_secret" {
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

variable "jwt_secret" {
  type = string
}

variable "token_life" {
  type = string
}

variable "database_server_endpoint" {
  type = string
}

variable "database_server_username" {
  type = string
}

variable "database_server_password" {
  type = string
}

variable "database_name" {
  type = string
}

variable "administrative_password" {
  type = string
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "terraform-ecs-demonstration-remote-state-bucket"
    key    = "terraform-remote-state-key"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "./s3"
  bucket_name = "demo-application-s3-bucket"
}

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

  google_recaptcha_secret = var.google_recaptcha_secret

  aws_access_key_id = var.aws_access_key_id

  aws_secret_access_key = var.aws_secret_access_key

  aws_region = var.aws_region

  jwt_secret = var.jwt_secret

  token_life = var.token_life

  database_server_endpoint = var.database_server_endpoint

  database_server_username = var.database_server_username

  database_server_password = var.database_server_password

  database_name = var.database_name

  administrative_password = var.administrative_password
}
