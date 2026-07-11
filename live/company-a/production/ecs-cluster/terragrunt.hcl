include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules//ecs-cluster"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  name_prefix = "${local.account_vars.locals.company_name}-${local.env_vars.locals.environment}"
}

inputs = {
  name_prefix = local.name_prefix
}
