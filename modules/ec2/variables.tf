variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
}
