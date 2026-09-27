terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # IMPORTANT: update "bucket" to match the bucket name you created in bootstrap/
  # Run `terraform init` here AFTER the bootstrap bucket exists — Terraform will
  # ask to migrate state to S3, type "yes".
  backend "s3" {
    bucket       = "terraform-state-bucket-for-ubuntu-12345"
    key          = "assignment5/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true # native S3 state locking (Terraform 1.9+), no DynamoDB needed
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance-RemoteState"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}
