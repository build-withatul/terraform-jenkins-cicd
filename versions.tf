
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "terraform-jenkins-cicd-atul-25"
    key    = "terraform-jenkins-cicd/terraform.tfstate"
    region = "ap-south-1"
  }
}
