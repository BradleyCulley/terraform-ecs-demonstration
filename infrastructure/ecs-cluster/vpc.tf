resource "aws_default_vpc" "default_vpc" {
}

data "aws_subnet_ids" "vpc_subnet_ids" {
  vpc_id = aws_default_vpc.default_vpc.id
}
