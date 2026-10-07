data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "terraform_cicd" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  monitoring    = true
  ebs_optimized = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name        = "terraform-jenkins-cicd"
    Environment = "stage"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "terraform-cicd-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "terraform-cicd-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
