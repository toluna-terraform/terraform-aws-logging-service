resource "aws_ecs_cluster" "logstash_cluster" {
  name = "ecs-${var.env_name}-logstash"

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "logstash_service" {
  name            = "ecs-${var.env_name}-logstash-service"
  cluster         = aws_ecs_cluster.logstash_cluster.id
  #task_definition = aws_ecs_task_definition.logstash_task_definition.arn
  task_definition = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/td-${var.env_name}-logstash:latest"
  desired_count   = 1
  iam_role        = aws_iam_role.task_execution_role.arn
  depends_on      = [aws_iam_role_policy.td_role_policy]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.logstash_tg.arn
    container_name   = "logstash"
    container_port   = 5140
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}


resource "aws_lb_target_group" "logstash_tg" {
  name        = "tg-${var.env_name}-logstash"
  port        = 5140
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "logstash_http_tg" {
  name        = "tg-${var.env_name}-logstash-http"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}


resource "aws_lb" "logstash_lb" {
  name               = "nlb-${var.env_name}-logstash"
  internal           = true
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb_sg.id]
  #subnets            = aws_subnet.public.*.id
  subnets            = var.subnets

  enable_deletion_protection = true

  access_logs {
    prefix  = "logstash_lb"
    enabled = true
  }

  tags = {
    Environment = ""
  }
}

resource "aws_lb_listener" "logstash_lb_listener_5140" {
  load_balancer_arn = aws_lb.logstash_lb.arn
  port              = "5140"
  protocol          = "TCP_UDP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.logstash_tg.arn
  }
}

resource "aws_lb_listener" "logstash_lb_listener_8080" {
  load_balancer_arn = aws_lb.logstash_lb.arn
  port              = "8080"
  protocol          = "TCP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.logstash_http_tg.arn
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${env_name}-logstash-role"
  assume_role_policy = data.aws_iam_policy_document.td_assume_role_policy.json
}

resource "aws_iam_role_policy" "td_role_policy" {
  name   = "task_execution_policy"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.td_role_policy.json
}