variable "name_prefix" {
  description = "Prefix used to name and tag resources created by this module, e.g. \"company-a-production\"."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per availability zone."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets, one per availability zone. Must be the same length as public_subnet_cidrs."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

check "subnet_cidr_pairing" {
  assert {
    condition     = length(var.public_subnet_cidrs) == length(var.private_subnet_cidrs)
    error_message = "public_subnet_cidrs and private_subnet_cidrs must have the same length (one pair per AZ)."
  }
}
