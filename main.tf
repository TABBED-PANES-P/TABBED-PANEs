# Declare the aws_region variable
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"  # You can change this to any region you prefer
}

# Declare the s3 bucket name variable
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# Declare RDS instance variables
variable "db_instance_name" {
  description = "The name of the RDS instance"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges for Security Group"
  type        = list(string)
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region  # Referencing the aws_region variable
}

# Create a unique S3 Bucket with a sanitized name
resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name  # Using the s3_bucket_name variable

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
    cidr_blocks = var.allowed_ip_ranges  # Using allowed_ip_ranges from variables
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
  identifier          = var.db_instance_name  # Using the db_instance_name variable
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  username            = var.db_username  # Using the db_username variable
  password            = var.db_password  # Using the db_password variable
  db_name             = var.db_name      # Using the db_name variable
  publicly_accessible = true
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Associating security group
  
  backup_retention_period = 7
  multi_az               = false
  skip_final_snapshot    = true

  tags = {
    Name        = "MyRDSInstance"
    Environment = "Dev"
  }

  auto_minor_version_upgrade = true  # Ensure this is only set once

  # Enable RDS instance encryption for data-at-rest (recommended for production)
  storage_encrypted = true
}
