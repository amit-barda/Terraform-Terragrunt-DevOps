# Root Terragrunt configuration.
#
# Named `root.hcl` rather than `terragrunt.hcl` on purpose: Terragrunt
# treats every discovered `terragrunt.hcl` as an independently-validatable
# leaf config, which breaks for a root file that only makes sense when
# `include`d by a child (see
# https://docs.terragrunt.com/migrate/migrating-from-root-terragrunt-hcl).
#
# This file is included by every `live/<company>/<environment>/<component>/terragrunt.hcl`
# via `include "root" { path = find_in_parent_folders("root.hcl") }`.
#
# `find_in_parent_folders()` calls below are resolved relative to the CHILD terragrunt.hcl
# that includes this file (not relative to this file itself), which is what lets a single
# root config generate a different backend/provider per company+environment.

# CLI-level guardrail, independent of any module's own `required_version`.
terraform_version_constraint = ">= 1.5.0"

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  company_name  = local.account_vars.locals.company_name
  account_name  = local.account_vars.locals.account_name
  account_id    = local.account_vars.locals.account_id
  aws_role_name = local.account_vars.locals.aws_role_name

  environment = local.env_vars.locals.environment
  aws_region  = local.region_vars.locals.aws_region

  # The bucket/table that hold Terraform state live in a dedicated tooling
  # location and are NOT re-created per environment. They are expected to be
  # bootstrapped once, out-of-band (see README "State backend bootstrap").
  state_bucket_region = "us-east-1"
}

# ---------------------------------------------------------------------------
# Remote state: one S3 bucket + DynamoDB lock table per company/account,
# one state file per component (keyed by its path under live/).
# ---------------------------------------------------------------------------
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = "tfstate-${local.company_name}-${local.account_id}"

    # `path_relative_to_include()` returns OS-native path separators
    # (backslashes on Windows). Force forward slashes so the S3 state key is
    # identical regardless of whether this is applied from Windows or from
    # the Linux-based Azure DevOps agents.
    key     = "${replace(path_relative_to_include(), "\\", "/")}/terraform.tfstate"
    region  = local.state_bucket_region
    encrypt = true

    dynamodb_table = "tflock-${local.company_name}-${local.account_id}"

    s3_bucket_tags = {
      Company     = local.company_name
      Environment = local.environment
      ManagedBy   = "terraform"
    }

    dynamodb_table_tags = {
      Company     = local.company_name
      Environment = local.environment
      ManagedBy   = "terraform"
    }
  }
}

# ---------------------------------------------------------------------------
# AWS provider: dynamically assumes the deployment role in the target
# account for this company+environment. No account IDs or credentials are
# ever hardcoded outside of account.hcl placeholders.
# ---------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"

      # Safety net: refuse to apply if the assumed role ever resolves to the
      # wrong account (e.g. a misconfigured account.hcl).
      allowed_account_ids = ["${local.account_id}"]

      assume_role {
        role_arn     = "arn:aws:iam::${local.account_id}:role/${local.aws_role_name}"
        session_name = "terragrunt-${local.company_name}-${local.environment}"
      }

      default_tags {
        tags = {
          Company     = "${local.company_name}"
          Environment = "${local.environment}"
          ManagedBy   = "terraform"
        }
      }
    }
  EOF
}

# Deliberately no `generate "versions"` block here: each module under
# modules/ already declares its own required_version/required_providers in
# versions.tf, and Terragrunt copies that file into the same working
# directory as these generated files. Declaring it twice would just invite
# the two declarations drifting apart.

# Deliberately no blanket `inputs = merge(...)` here either: not every
# module declares variables for every key in account.hcl/env.hcl/region.hcl
# (e.g. modules/networking only takes `name_prefix`), and Terragrunt passes
# `inputs` as TF_VAR_* env vars - any that don't match a declared variable
# produce a "Value for undeclared variable" warning on every plan/apply.
# Each component's terragrunt.hcl reads account_vars/env_vars/region_vars
# itself and passes on only the specific inputs its target module declares.
