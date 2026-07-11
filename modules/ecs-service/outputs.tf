output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "service_id" {
  description = "ID of the ECS service."
  value       = aws_ecs_service.this.id
}

output "task_definition_arn" {
  description = "ARN of the task definition (includes revision)."
  value       = aws_ecs_task_definition.this.arn
}

output "security_group_id" {
  description = "ID of the service's security group."
  value       = aws_security_group.service.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group this service writes to."
  value       = aws_cloudwatch_log_group.this.name
}
