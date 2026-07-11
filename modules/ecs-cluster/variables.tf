variable "name_prefix" {
  description = "Prefix used to name and tag resources created by this module, e.g. \"company-a-production\"."
  type        = string
}

variable "container_insights_enabled" {
  description = "Whether to enable CloudWatch Container Insights (enhanced container-level metrics) on the cluster. Required to stay enabled per this org's observability standard."
  type        = bool
  default     = true
}

variable "default_capacity_provider" {
  description = "Which capacity provider (\"FARGATE\" or \"FARGATE_SPOT\") new services land on by default when they don't specify their own capacity_provider_strategy."
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "FARGATE_SPOT"], var.default_capacity_provider)
    error_message = "default_capacity_provider must be either \"FARGATE\" or \"FARGATE_SPOT\"."
  }
}
