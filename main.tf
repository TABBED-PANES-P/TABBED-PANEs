# main.tf

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name
  acl    = "private"
}

resource "aws_instance" "example" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type

  tags = {
    Name = "example-instance"
  }
}
