locals {
  security_group = "sgr-${var.env_name}-dc-internal"
  load_balancers = [{"target_group_arn":"${data.aws_lb_target_group.tg-8080.arn}","container_name":"logstash","container_port":8080},{"target_group_arn":"${data.aws_lb_target_group.tg-5140.arn}","container_name":"logstash","container_port":5140}]
  service_name   = "${var.env_name}-logstash"
  ecs_name   = "${var.env_name}-devops-tools"
  task_definition_family = "logstash"
}

resource "aws_ecs_cluster" "logging_cluster" {
  name = "ecs-${local.ecs_name}"
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(
    var.tags,
    tomap({
      "Name" = "${local.service_name}",
      "environment" = "${var.env_name}",
      "application_role" = "logging",
      "created_by" = "terraform"
    })
  )
}

resource "aws_ecs_service" "logging_service" {
  name            = "ecs-${local.service_name}-service"
  cluster         = aws_ecs_cluster.logging_cluster.id
  task_definition = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/td-${var.env_name}-logstash:${data.aws_ecs_task_definition.logstash.revision}"
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_iam_role_policy.td_role_policy]
  tags = merge(
    var.tags,
    tomap({
      "Name" = "${local.service_name}",
      "environment" = "${var.env_name}",
      "application_role" = "logging",
      "created_by" = "terraform"
    })
  )
  network_configuration {
    security_groups  = [data.aws_security_group.selected.id,aws_security_group.logging_sg.id]
    subnets          = var.subnets
  }


  dynamic "load_balancer" {
    for_each = local.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }
}

resource "aws_lb_target_group" "logging_tg" {
  name        = "tg-ecs-${local.service_name}"
  port        = 5140
  protocol    = "TCP_UDP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    tomap({
      "Name" = "${local.service_name}",
      "environment" = "${var.env_name}",
      "application_role" = "logging",
      "created_by" = "terraform"
    })
  )
}

resource "aws_lb_target_group" "logging_http_tg" {
  name        = "tg-ecs-${local.service_name}-http"
  port        = 8080
  protocol    = "TCP_UDP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    tomap({
      "Name" = "${local.service_name}",
      "environment" = "${var.env_name}",
      "application_role" = "logging",
      "created_by" = "terraform"
    })
  )
}


resource "aws_lb" "logging_lb" {
  name               = "nlb-ecs-${local.service_name}"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnets
  enable_deletion_protection = false
  tags = merge(
    var.tags,
    tomap({
      "Name" = "${local.service_name}",
      "environment" = "${var.env_name}",
      "application_role" = "logging",
      "created_by" = "terraform"
    })
  )
}

resource "aws_lb_listener" "logging_lb_listener_5140" {
  load_balancer_arn = aws_lb.logging_lb.arn
  port              = "5140"
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.logging_tg.arn
  }
}

resource "aws_lb_listener" "logging_lb_listener_8080" {
  load_balancer_arn = aws_lb.logging_lb.arn
  port              = "8080"
  protocol          = "TCP"

 default_action {
   type             = "forward"
    target_group_arn = aws_lb_target_group.logging_http_tg.arn
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.service_name}-role"
  assume_role_policy = data.aws_iam_policy_document.td_assume_role_policy.json
}

resource "aws_iam_role_policy" "td_role_policy" {
  name   = "task_execution_policy"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.td_role_policy.json
}

resource "aws_route53_record" "logging_service_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "logging"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.logging_lb.dns_name]
}

resource "aws_ecs_task_definition" "service_td" {
  count                    = var.task_definition_already_exists ? 0 : 1
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 16384
  family                   = "td-${var.env_name}-${local.task_definition_family}"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = templatefile("${path.module}/templates/logstash.json.tpl",{ ENV_NAME = var.env_name, SHORT_ENV_NAME = var.short_env_name }) 
  task_role_arn            = "${data.aws_iam_role.taskExecutionRole.arn}"
  execution_role_arn       = "${data.aws_iam_role.taskExecutionRole.arn}"
  lifecycle {
    ignore_changes = all
   }
}


resource "aws_security_group" "logging_sg" {
  name        = local.service_name
  description = "Security-Group for Logging service."
  vpc_id      = var.vpc_id

 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    tomap({
      "Name" = "${local.service_name}",
      "itwp-environment" = "${var.env_name}",
      "dc" = "sg_test",
      "itwp-application_role" = "network",
      "created_by" = "terraform"
    })
  )
}

resource "aws_security_group_rule" "tcp_5140" {
  type              = "ingress"
  from_port         = 5140
  to_port           = 5140
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.logging_sg.id
  description       = "Allow 5140 TCP from VPC" 
}

resource "aws_security_group_rule" "udp_5140" {
  type              = "ingress"
  from_port         = 5140
  to_port           = 5140
  protocol          = "udp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.logging_sg.id
  description       = "Allow 5140 UDP from VPC" 
}

resource "aws_security_group_rule" "tcp_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.logging_sg.id
  description       = "Allow 8080 TCP from VPC" 
}
