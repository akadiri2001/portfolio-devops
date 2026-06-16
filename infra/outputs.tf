output "ecr_repository_url" {
  description = "URL du registre ECR"
  value       = aws_ecr_repository.portfolio.repository_url
}

output "alb_dns_name" {
  description = "URL publique du portfolio"
  value       = "http://${aws_lb.main.dns_name}"
}
