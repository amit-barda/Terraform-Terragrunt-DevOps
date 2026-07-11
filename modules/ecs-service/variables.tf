variable "name_prefix" {
  description = "Prefix used to name and tag resources created by this module, e.g. \"company-a-production\"."
  type        = string
}

variable "service_name" {
  description = "Short name of this service, e.g. \"nginx\". Used to build resource names and the container name."
  type        = string
}

variable "image" {
  description = "Container image to run, e.g. \"nginx:stable\"."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on and that the ALB target group forwards to."
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of task copies to run. Defaults to 2 to spread across both AZs."
  type        = number
  default     = 2
}

variable "capacity_provider" {
  description = "Which capacity provider (\"FARGATE\" or \"FARGATE_SPOT\") this service runs on."
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "FARGATE_SPOT"], var.capacity_provider)
    error_message = "capacity_provider must be either \"FARGATE\" or \"FARGATE_SPOT\"."
  }
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period for this service's log group."
  type        = number
  default     = 30
}

variable "vpc_id" {
  description = "ID of the VPC to create the service's security group in."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets the service's tasks run in."
  type        = list(string)
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to deploy this service into."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB that's allowed to reach this service on container_port."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group this service registers its tasks with."
  type        = string
}
