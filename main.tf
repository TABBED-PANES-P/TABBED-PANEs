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

# Unique DB Subnet Group with environment suffix
resource "aws_db_subnet_group" "default" {
  name       = "mysql-db-subnet-group-${var.environment}"
  subnet_ids = slice(data.aws_subnets.available.ids, 0, 2)
  tags = {
    Name        = "mysql-db-subnet-group-${var.environment}"
    Environment = var.environment
  }
}

# Unique Security Group with environment suffix
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
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = var.publicly_accessible
  
  tags = {
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [password]
  }
}
