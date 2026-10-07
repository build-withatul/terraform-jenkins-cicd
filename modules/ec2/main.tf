resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
