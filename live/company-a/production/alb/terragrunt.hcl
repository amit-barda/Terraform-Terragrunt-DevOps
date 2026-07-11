include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules//alb"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  name_prefix  = "${local.account_vars.locals.company_name}-${local.env_vars.locals.environment}"
  company_name = local.account_vars.locals.company_name
}

dependency "networking" {
  config_path = "../networking"

  # Lets `plan`/`validate` run before networking has ever been applied.
  # `apply` is deliberately NOT in this list - applying the ALB against a
  # made-up VPC/subnet ID would silently create broken infrastructure, so
  # apply must fail loudly until networking has real outputs.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    vpc_id            = "vpc-00000000000000000"
    public_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }
}

inputs = {
  name_prefix       = local.name_prefix
  vpc_id            = dependency.networking.outputs.vpc_id
  public_subnet_ids = dependency.networking.outputs.public_subnet_ids

  routing_rules = [
    {
      name              = "nginx"
      host_header       = "nginx.${local.company_name}.example.com"
      port              = 80
      health_check_path = "/"
    }
  ]
}
