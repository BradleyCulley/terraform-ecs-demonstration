variable "repository_url" {
  type = string
}

variable "service_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "port" {
  type = number
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

variable "vpc_subnet_ids" {
  type = list(string)
}

variable "ecs_task_role_name" {
  type = string
}

resource "aws_ecs_task_definition" "service" {
  family = "frontend-service-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions    = <<DEFINITION
  [
    {
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/demo-application-backend-cloudwatch-group",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "hostPort": ${var.port},
          "protocol": "tcp",
          "containerPort": ${var.port}
        }
      ],
      "image": "${var.repository_url}:${var.image_tag}",
      "healthCheck": {
        "retries": 3,
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost || exit 0"
        ],
        "timeout": 5,
        "interval": 30
      },
      "essential": true,
      "name": "demo-application-${var.service_name}-container",
      "environment" : [
          { "name" : "AWS_ACCESS_KEY_ID", "value" : "${var.aws_access_key_id}" },
          { "name" : "AWS_SECRET_ACCESS_KEY", "value" : "${var.aws_secret_access_key}" },
          { "name" : "AWS_REGION", "value" : "${var.aws_region}" },
          { "name" : "CUSTOM_NODE_PORT", "value" : "443" }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.service_name}-ecs-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  launch_type = "FARGATE"
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    container_name   = "demo-application-${var.service_name}-container"
    container_port   = aws_alb_target_group.alb_target_group.port
  }

  network_configuration {
    subnets         = var.vpc_subnet_ids
    security_groups = [aws_security_group.security_group.id]
    assign_public_ip = true
  }
}
