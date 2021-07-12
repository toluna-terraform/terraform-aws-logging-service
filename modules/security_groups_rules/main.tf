resource "aws_security_group_rule" "cidr_rules" {
  for_each          = var.cidr_rules
  security_group_id = var.security_groups[0][each.value.name]["id"]
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks == "local" ? [var.vpc_cidr] : [each.value.cidr_blocks]
  description       = each.value.description
}


resource "aws_security_group_rule" "sg_rules" {
  for_each                 = var.sg_rules
  security_group_id        = var.security_groups[0][each.value.name]["id"]
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = try(var.security_groups[0][each.value.security_groups]["id"],each.value.security_groups)
  description              = each.value.description
}


resource "aws_security_group_rule" "self_rules" {
  for_each          = var.self_rules
  security_group_id = var.security_groups[0][each.value.name]["id"]
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  self              = true
  description       = each.value.description
}
