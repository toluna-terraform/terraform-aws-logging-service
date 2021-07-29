variable "env_name" {
    type = string
    default = "qa-c"
}

variable "vpc_id" {
  type = string
  default = "vpc-0947d6d2d655a2993"
}

variable "subnets" {
    type = list(string)
    default = ["subnet-0efa886b2637523f5","subnet-0d18be197aec0d5cf","subnet-07b25e2c4be5cea17"]
}

variable "hosted_zone" {
  type = string
  description = "Route53 Hosted Zone Domain Name"
  default = "qac.tolunainsights-internal.com"
}