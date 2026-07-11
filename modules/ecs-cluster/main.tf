# ECS cluster running exclusively on Fargate / Fargate Spot (no EC2 capacity
# to manage), with Container Insights enabled for cluster/service/task-level
# CloudWatch metrics.

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = var.default_capacity_provider
    base              = 1
    weight            = 100
  }
}
