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

module "ec2" {
  source = "../../modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  name                 = "terraform-stage"
  environment          = var.environment
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}

resource "aws_iam_role" "ec2_role" {
  name = "terraform-cicd-stage-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "terraform-cicd-stage-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
