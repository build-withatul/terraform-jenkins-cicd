terraform {
  backend "s3" {
    bucket       = "terraform-jenkins-cicd-atul-25"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
