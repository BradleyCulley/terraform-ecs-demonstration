variable "frontend_repository_url" {
  type = string
}

variable "backend_repository_url" {
  type = string
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

variable "acm_certificate_arn" {
  type = string
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "demo-application-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "ecs-service-frontend" {
  source = "./frontend-ecs-service"

  service_name = "frontend"

  cluster_id = aws_ecs_cluster.ecs_cluster.id

  ecs_task_role_arn = aws_iam_role.ecs_task_role.arn

  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  repository_url = var.frontend_repository_url

  port = 80

  server_address = module.ecs-service-backend.alb_dns_name

  server_port = 443

  image_tag = var.image_tag

  vpc_subnet_ids = data.aws_subnet_ids.vpc_subnet_ids.ids

  default_vpc_id = aws_default_vpc.default_vpc.id

  acm_certificate_arn = var.acm_certificate_arn
}

module "ecs-service-backend" {
  source = "./backend-ecs-service"

  service_name = "backend"

  cluster_id = aws_ecs_cluster.ecs_cluster.id

  ecs_task_role_arn = aws_iam_role.ecs_task_role.arn

  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  repository_url = var.backend_repository_url

  port = 443

  vpc_subnet_ids = data.aws_subnet_ids.vpc_subnet_ids.ids

  default_vpc_id = aws_default_vpc.default_vpc.id

  acm_certificate_arn = var.acm_certificate_arn

  ecs_task_role_name = aws_iam_role.ecs_task_role.name

  image_tag = var.image_tag

  aws_access_key_id = var.aws_access_key_id

  aws_secret_access_key = var.aws_secret_access_key

  aws_region = var.aws_region
}

output "frontend_alb_dns_name" {
  value = module.ecs-service-frontend.alb_dns_name
}

output "backend_alb_dns_name" {
  value = module.ecs-service-backend.alb_dns_name
}

output "alb_zone_id" {
  value = module.ecs-service-frontend.alb_zone_id
}
