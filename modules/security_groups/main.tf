resource "aws_security_group" "this" {
  for_each    = var.sgs
  name        = "sgr-${var.env_name}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    map(
      "Name", "sgr-${var.env_name}-${each.key}",
      "itwp-environment", var.env_name,
      "dc", "sg_test",
      "itwp-application_role", "network",
      "created_by", "terraform"
    )
  )

}
