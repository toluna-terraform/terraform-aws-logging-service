variable "env_name" {
    type = string
    default = "shared-srv-qa"
}

variable "vpc_id" {
  type = string
  default = "vpc-0947d6d2d655a2993"
}

variable "subnets" {
    type = list(string)
}

variable "security_groups" {
  type = list(string)
}