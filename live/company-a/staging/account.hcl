locals {
  company_name = "company-a"
  account_name = "company-a-staging"

  # Placeholder AWS account ID - replace with the real staging account ID.
  account_id = "111111111111"

  # IAM role Terragrunt assumes in the target account to deploy resources.
  aws_role_name = "TerragruntDeploymentRole"
}
