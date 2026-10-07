resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  monitoring    = true
  ebs_optimized = true

  metadata_options {
    http_tokens = "required"
  }

  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
