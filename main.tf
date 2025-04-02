provider "aws" {
  region = "us-east-1"  # Adjust this to the region you want to use
}

# Create an S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket-abc123-xyz789"  # Ensure this name is unique

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
    cidr_blocks = ["0.0.0.0/0"]  # For wide access, but not recommended for production
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
  identifier          = "my-db-instance"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  username            = "admin"
  password            = "admin1234"  # Change this to a more secure password
  db_name             = "mydb"
  publicly_accessible = true
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Associating security group
  
  backup_retention_period = 7
  multi_az               = false
  allocated_storage      = 20
  skip_final_snapshot    = true

  tags = {
    Name        = "MyRDSInstance"
    Environment = "Dev"
  }

  auto_minor_version_upgrade = true
}
