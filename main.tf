# main.tf
provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Use the appropriate AMI for your region
  instance_type = var.instance_type

  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_db_instance" "example" {
  identifier        = "example-db"
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  db_name           = "exampledb"
  skip_final_snapshot = true

  tags = {
    Name = "ExampleDatabase"
  }
}
