terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Mumbai region — change if you want
}

resource "aws_instance" "app_server" {
  ami           = "ami-01a00762f46d584a1" # Ubuntu Linux 2023 - ap-south-1 
  instance_type = "t2.micro"              # Free tier eligible

  tags = {
    Name = "AppServerInstance"
  }
}
