output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.terraform_cicd.id
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.terraform_cicd.private_ip
}
