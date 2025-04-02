# Declare the AWS region as a variable with a default value
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"  # You can change this to any region you prefer
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region  # Referencing the aws_region variable
}

# Declare variables for the S3 Bucket and RDS instance with default values
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "my-unique-terraform-bucket-123"
}

variable "db_instance_name" {
  description = "The name of the RDS instance"
  type        = string
  default     = "my-db-instance"
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  default     = "SuperSecureP@ssw0rd!"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges for Security Group"
  type        = list(string)
  default     = ["192.168.1.0/24", "10.0.0.0/16"]
}

# Configure the S3 Bucket resource
resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name  # Referencing the variable for the bucket name

  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}

# Create a Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_ranges  # Using variable for allowed IP ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyRdsSecurityGroup"
  }
}

# Create an RDS instance and associate the security group
resource "aws_db_instance" "example" {
  identifier          = var.db_instance_name  # Using variable for DB instance name
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20  # Set storage size
  storage_type        = "gp2"
  username            = var.db_username  # Using variable for DB username
  password            = var.db_password  # Using variable for DB password
  db_name             = var.db_name      # Using variable for DB name
  publicly_accessible = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Associating the security group

  backup_retention_period = 7
  multi_az               = false
  skip_final_snapshot    = true

  tags = {
    Name        = "MyRDSInstance"
    Environment = "Dev"
  }

  auto_minor_version_upgrade = true
}
