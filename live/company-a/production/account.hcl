locals {
  company_name = "company-a"
  account_name = "company-a-production"

  # Placeholder AWS account ID - replace with the real production account ID.
  # Deliberately DIFFERENT from staging: production is isolated in its own
  # AWS account (blast-radius / IAM boundary).
  account_id = "222222222222"

  # IAM role Terragrunt assumes in the target account to deploy resources.
  aws_role_name = "TerragruntDeploymentRole"
}
