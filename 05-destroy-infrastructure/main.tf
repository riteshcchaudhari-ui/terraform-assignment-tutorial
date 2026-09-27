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
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

# This tutorial is only about running: terraform destroy
# Steps:
# 1. terraform init
# 2. terraform apply -auto-approve
# 3. terraform destroy   <-- this is the actual learning objective here
