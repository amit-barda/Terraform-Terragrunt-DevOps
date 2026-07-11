output "alb_arn" {
  description = "ARN of the ALB."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB (CNAME target for e.g. nginx.company-a.example.com)."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Route 53 hosted zone ID of the ALB, for alias records."
  value       = aws_lb.this.zone_id
}

output "alb_security_group_id" {
  description = "ID of the ALB's security group, so backend services can allow ingress from it specifically."
  value       = aws_security_group.alb.id
}

output "target_group_arns" {
  description = "Map of routing rule name to its target group ARN, e.g. { nginx = \"arn:...\" }."
  value       = { for name, tg in aws_lb_target_group.this : name => tg.arn }
}
