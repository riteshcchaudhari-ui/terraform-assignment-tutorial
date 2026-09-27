terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t2.micro"

  # CHANGED: instance_type and tag updated to demonstrate "terraform plan/apply" on existing infra
  tags = {
    Name = "AppServerInstance-Updated"
  }
}
