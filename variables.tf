variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  default     = "prod"
}

variable "mysql_version" {
  description = "MySQL version"
  default     = "8.0.33"
}

variable "instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage size in GB"
  default     = 20
}

variable "db_name" {
  description = "Database name"
  default     = "applicationdb"
}

variable "db_username" {
  description = "Database admin username"
  default     = "admin"
}

variable "db_password" {
  type        = string
  description = "The password for the database."
  sensitive   = true

  validation {
    condition = length(var.db_password) >= 8 && length(var.db_password) <= 41 &&
                !(var.db_password =~ "/") &&
                !(var.db_password =~ "@") &&
                !(var.db_password =~ "\"") &&
                !(var.db_password =~ " ")

    error_message = "Password must be between 8 and 41 characters and contain only printable ASCII characters excluding /, @, \" or spaces."
  }
}

variable "allowed_cidr" {
  description = "Allowed CIDR block for MySQL access"
  default     = "10.0.0.0/16"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  default     = true
}

variable "publicly_accessible" {
  description = "Make RDS publicly accessible"
  default     = false
}

# Add these to fix the warnings
variable "s3_bucket_name" {
  description = "S3 bucket name"
  default     = ""
}

variable "aws_ami_id" {
  description = "AWS AMI ID"
  default     = ""
}

variable "unique_suffix" {
  description = "Unique identifier to prevent conflicts"
  type        = string
  default     = "" # Will be set in Jenkinsfile
}
