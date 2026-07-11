include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules//ecs-service"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  name_prefix = "${local.account_vars.locals.company_name}-${local.env_vars.locals.environment}"
}

dependency "networking" {
  config_path = "../../networking"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
  }
}

dependency "ecs_cluster" {
  config_path = "../../ecs-cluster"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    cluster_arn = "arn:aws:ecs:us-east-1:222222222222:cluster/mock-cluster"
  }
}

dependency "alb" {
  config_path = "../../alb"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    alb_security_group_id = "sg-00000000000000000"
    target_group_arns = {
      nginx = "arn:aws:elasticloadbalancing:us-east-1:222222222222:targetgroup/mock-nginx-tg/0000000000000000"
    }
  }
}

inputs = {
  name_prefix = local.name_prefix

  service_name   = "nginx"
  image          = "nginx:stable"
  container_port = 80

  vpc_id             = dependency.networking.outputs.vpc_id
  private_subnet_ids = dependency.networking.outputs.private_subnet_ids

  cluster_arn = dependency.ecs_cluster.outputs.cluster_arn

  alb_security_group_id = dependency.alb.outputs.alb_security_group_id
  target_group_arn      = dependency.alb.outputs.target_group_arns["nginx"]
}
