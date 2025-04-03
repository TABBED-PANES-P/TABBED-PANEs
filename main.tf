# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all available subnets
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# DB Subnet Group with lifecycle management
resource "aws_db_subnet_group" "default" {
  name       = "mysql-db-subnet-group-${var.environment}"
  subnet_ids = slice(data.aws_subnets.available.ids, 0, 2)
  tags = {
    Name        = "mysql-db-subnet-group-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group with lifecycle management
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg-${var.environment}"
  description = "MySQL security group for ${var.environment}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "mysql-sg-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# MySQL RDS Instance (NO CHANGES NEEDED)
resource "aws_db_instance" "mysql" {
  # ... keep all existing configuration exactly as is ...
}
