provider "aws" {
  region = "us-west-2"  # Adjust the region as needed
}

# Security Group allowing access to MySQL
resource "aws_security_group" "default" {
  name_prefix = "db_sg_"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to public for demo (change for production)
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

# Create the first RDS MySQL instance
resource "aws_db_instance" "mysql_instance_1" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase1"
  username             = "admin"
  password             = "yourpassword"
  skip_final_snapshot  = true
  multi_az             = false
  publicly_accessible  = false
  backup_retention_period = 7

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"

  tags = {
    Name = "MySQLInstance1"
  }
}

# Create the second RDS MySQL instance
resource "aws_db_instance" "mysql_instance_2" {
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase2"
  username             = "admin"
  password             = "anotherpassword"
  skip_final_snapshot  = true
  multi_az             = false
  publicly_accessible  = false
  backup_retention_period = 7

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"

  tags = {
    Name = "MySQLInstance2"
  }
}
