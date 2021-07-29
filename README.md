# terraform-aws-logging-service

```module "logging_service"{
  source = "../../../../toluna-terraform/terraform-aws-logging-service/"
  env_name = local.main.env_name
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids
  hosted_zone = "qac.tolunainsights-internal.com"
}```
