data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_role" "taskExecutionRole" {
  name = "taskExecutionRole"
}

data "aws_iam_policy_document" "td_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "td_role_policy" {
  statement {
    actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    resources = [
        "*"
    ]
  }
}

data "aws_ecs_task_definition" "logstash" {
  task_definition = "td-${var.env_name}-logstash"
  depends_on = [ aws_ecs_task_definition.service_td ]
}

data "aws_security_group" "selected" {
  name = local.security_group
}

data "aws_lb_target_group" "tg-8080" {
  name = "tg-ecs-${var.env_name}-log-8080"
  depends_on  = [aws_lb_target_group.logging_http_tg]
}

data "aws_lb_target_group" "tg-5140" {
  name = "tg-ecs-${var.env_name}-log-5140"
  depends_on  = [aws_lb_target_group.logging_tg]
}

data "aws_route53_zone" "selected" {
  name         = var.hosted_zone
  private_zone = true
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ssm_parameter" "opensearch_datadog_api" {
  name = "opensearch_datadog_api"
}