variable "instance_type" {
  description = "The type of EC2 instance for the RDS instance"
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Database administrator username"
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "The S3 bucket name"
}

variable "aws_ami_id" {
  description = "The AMI ID"
}
