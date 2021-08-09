locals {
  service_name = "sgr-${var.env_name}-logging"
}
resource "aws_security_group" "logging_sg" {
  name        = local.service_name
  description = "Security-Group for Logging service."
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = var.vpc_cidr
    },
    {
      description      = "5140 TCP from VPC"
      from_port        = 5140
      to_port          = 5140
      protocol         = "tcp"
      cidr_blocks      = var.vpc_cidr
    },
    {
      description      = "5140 UDP from VPC"
      from_port        = 5140
      to_port          = 5140
      protocol         = "udp"
      cidr_blocks      = var.vpc_cidr
    },
    {
      description      = "8080 from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = var.vpc_cidr
    },
    {
      description      = "5140 from QA-T"
      from_port        = 5140
      to_port          = 5140
      protocol         = "tcp"
      cidr_blocks      = var.vpc_cidr
    },
    {
      description      = "5140 from QA-T"
      from_port        = 5140
      to_port          = 5140
      protocol         = "tcp"
      cidr_blocks      = var.vpc_cidr
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = local.service_name
  }
}