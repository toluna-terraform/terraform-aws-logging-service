locals {
  security_group = "sgr-${var.env_name}-dc-internal"
  load_balancers = [{"target_group_arn":"${data.aws_lb_target_group.tg-8080.arn}","container_name":"logstash","container_port":8080},{"target_group_arn":"${data.aws_lb_target_group.tg-5140.arn}","container_name":"logstash","container_port":5140}]
}

resource "aws_ecs_cluster" "logging_cluster" {
  name = "ecs-${var.env_name}-logging"
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "logging_service" {
  name            = "ecs-${var.env_name}-logging-service"
  cluster         = aws_ecs_cluster.logging_cluster.id
  task_definition = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/td-${var.env_name}-logstash:${data.aws_ecs_task_definition.logstash.revision}"
  desired_count   = 2
  launch_type = "FARGATE"
  depends_on      = [aws_iam_role_policy.td_role_policy]

  network_configuration {
    security_groups  = [data.aws_security_group.selected.id]
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
  name        = "tg-${var.env_name}-logging"
  port        = 5140
  protocol    = "TCP_UDP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "logging_http_tg" {
  name        = "tg-${var.env_name}-logging-http"
  port        = 8080
  protocol    = "TCP_UDP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}


resource "aws_lb" "logging_lb" {
  name               = "nlb-${var.env_name}-logging"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnets
  enable_deletion_protection = false

  tags = {
    Environment = "${var.env_name}"
  }
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
  name               = "${var.env_name}-logging-role"
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

