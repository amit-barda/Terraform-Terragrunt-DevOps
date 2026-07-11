variable "name_prefix" {
  description = "Prefix used to name and tag resources created by this module, e.g. \"company-a-production\"."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the ALB and its target groups are created in."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets the internet-facing ALB is deployed into (one per AZ)."
  type        = list(string)
}

variable "routing_rules" {
  description = <<-DESC
    Host-header based routing rules. Each entry creates one target group and
    one listener rule that forwards requests for that host header to it.
    Traffic that doesn't match any rule's host header falls through to the
    listener's default 404 response.
  DESC
  type = list(object({
    name              = string
    host_header       = string
    port              = number
    health_check_path = optional(string, "/")
  }))
  default = []
}
