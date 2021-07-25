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
}
