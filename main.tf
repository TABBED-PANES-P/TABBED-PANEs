# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Create an S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name
  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg"
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_ranges
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

# Create an RDS instance
resource "aws_db_instance" "example" {
  identifier          = var.db_instance_name
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  username            = var.db_username
  password            = var.db_password
  db_name             = var.db_name
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = 7
  multi_az               = false
  skip_final_snapshot    = true

  tags = {
    Name        = "MyRDSInstance"
    Environment = "Dev"
  }

  auto_minor_version_upgrade = true
}

