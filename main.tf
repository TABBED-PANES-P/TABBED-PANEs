# Configure AWS Provider
provider "aws" {
  region = "us-east-1"  # Change to your region
}

# Get the default VPC (or specify a custom VPC)
data "aws_vpc" "default" {
  default = true  # Set to `false` if using a custom VPC
}

# Fetch all available subnets in the VPC
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create an RDS subnet group (must have at least 2 subnets in different AZs)
resource "aws_db_subnet_group" "default" {
  name       = "mysql-db-subnet-group"
  subnet_ids = slice(data.aws_subnets.available.ids, 0, 2)  # Takes first 2 subnets
  tags = {
    Name = "MySQL DB Subnet Group"
  }
}

# Security Group for MySQL
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Allow inbound MySQL traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306  # MySQL default port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production!
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
  identifier             = "mysql-db-instance"
  engine                 = "mysql"
  engine_version         = "8.0.33"  # Latest stable MySQL 8.0 (check your region)
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "mydatabase"
  username               = "admin"
  password               = "changeme123"  # Use AWS Secrets Manager in production!
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  skip_final_snapshot    = true  # Set to `false` in production!
}
