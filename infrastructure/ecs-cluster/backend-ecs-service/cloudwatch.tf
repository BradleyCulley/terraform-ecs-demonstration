resource "aws_cloudwatch_log_group" "demo-application-cloudwatch-group_backend" {
  name = "/ecs/${var.service_name}-cloudwatch-group"
}
