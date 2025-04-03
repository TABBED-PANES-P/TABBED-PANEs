provider "aws" {
  region = "us-west-2"  # Adjust as needed
}

# Security Group allowing MySQL traffic
resource "aws_security_group" "default" {
  name_prefix = "db_sg_"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the public for demo (change for production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# Define DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = ["subnet-xxxxxx", "subnet-yyyyyy"]  # Replace with actual subnet IDs

  tags = {
    Name = "my-db-subnet-group"
  }
}

# Create the RDS MySQL instance
resource "aws_db_instance" "mysql_instance_1" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.instance_type
  db_name                 = "mydatabase"
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  multi_az                = false
  publicly_accessible     = false
  backup_retention_period = 7

  vpc_security_group_ids  = ["${aws_security_group.default.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.default.name}"

  tags = {
    Name = "MySQLInstance"
  }
}
