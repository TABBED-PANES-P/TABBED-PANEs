# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"  # You can change the default or override in terraform.tfvars
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "aws_ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "aws_instance_type" {
  description = "The type of EC2 instance"
  type        = string
}
