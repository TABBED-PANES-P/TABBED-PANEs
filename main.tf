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

# Create an RDS subnet group using the first 2 subnets (must be in different AZs)
resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = slice(data.aws_subnets.available.ids, 0, 2)  # Takes first 2 subnets
  tags = {
    Name = "Dynamic DB Subnet Group"
  }
}

# Example: RDS Security Group (optional but recommended)
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound PostgreSQL/Aurora traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
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

# Example: Create a PostgreSQL RDS instance (optional)
resource "aws_db_instance" "example" {
  identifier             = "my-postgres-db"
  engine                 = "postgres"
  engine_version         = "14.4"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "mydatabase"
  username               = "admin"
  password               = "changeme123"  # Use AWS Secrets Manager in production!
 
  skip_final_snapshot    = true  # Set to `false` in production!
}
