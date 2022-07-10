resource "aws_cloudwatch_log_group" "demo-application-cloudwatch-group_frontend" {
  name = "/ecs/${var.service_name}-cloudwatch-group"
}
