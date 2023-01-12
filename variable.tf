variable "env_name" {
    type = string
}

variable "api_key" {
    type = string
}

variable "short_env_name" {
    type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
    type = list(string)
}

variable "hosted_zone" {
  type = string
  description = "Route53 Hosted Zone Domain Name"
}

variable "tags" {
  
}

variable "task_definition_already_exists" {
  default = true
}

variable "security_group_rules" {
  
}