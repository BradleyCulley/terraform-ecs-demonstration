variable "rds_database_password" {
  type = string
}

variable "rds_database_username" {
  type = string
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_security_group" "security_group" {
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = # TODO allow ingress only from the backend security group,
    # and allow backend to only have ingress from frontend security group,
    # once moving to production-like setup
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "database" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.23"
  instance_class       = "db.t2.micro"
  name                 = "demo-application"
  username             = var.rds_database_username
  password             = var.rds_database_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.security_group.id]
}

output "rds_endpoint" {
  value = aws_db_instance.database.endpoint
}
