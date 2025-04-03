# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Get VPC and Subnets
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# MySQL RDS Subnet Group
resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnet-group-${var.environment}"
  subnet_ids = data.aws_subnets.available.ids
  tags = {
    Environment = var.environment
  }
}

# Security Group
resource "aws_security_group" "mysql" {
  name        = "mysql-sg-${var.environment}"
  description = "Allow MySQL access"
  vpc_id      = data.aws_vpc.selected.id

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
}

# MySQL RDS Instance
resource "aws_db_instance" "mysql" {
  identifier             = "mysql-${var.environment}"
  engine                 = "mysql"
  engine_version         = var.mysql_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  skip_final_snapshot    = var.skip_final_snapshot
  parameter_group_name   = "default.mysql${replace(var.mysql_version, "/\\..*/", "")}"
  publicly_accessible    = var.publicly_accessible
  storage_type           = "gp2"
  backup_retention_period = 7
  tags = {
    Environment = var.environment
  }
}
