variable "env_name" {
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
