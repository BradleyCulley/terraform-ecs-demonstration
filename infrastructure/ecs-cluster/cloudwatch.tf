resource "aws_cloudwatch_log_group" "demo-application-cloudwatch-group_frontend" {
  name = "/ecs/demo-application-frontend-cloudwatch-group"
}
resource "aws_cloudwatch_log_group" "demo-application-cloudwatch-group_backend" {
  name = "/ecs/demo-application-backend-cloudwatch-group"
}
