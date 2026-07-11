include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Resolved relative to the repo root (the directory containing root.hcl),
# not via `get_repo_root()`, so this works even outside a git repository.
terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules//networking"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  name_prefix = "${local.account_vars.locals.company_name}-${local.env_vars.locals.environment}"
}

inputs = {
  name_prefix = local.name_prefix

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}
