provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name
  acl    = "private"
}

resource "aws_instance" "example" {
  ami           = var.aws_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "example-instance"
  }
}

# Add RDS configuration if needed
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  name                = "mydb"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
}
