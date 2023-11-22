terraform {
 required_providers {
   aws = {
     source = "hashicorp/aws"
     version = "~> 4.16"
   }
 }

 required_version = ">= 1.2.0"
}

provider "aws" {
 region  = "us-east-1"
 profile = "default"
}

resource "aws_instance" "example_server" {
 ami           = "ami-0230bd60aa48260c6"
 instance_type = "t2.micro"
 key_name      = "sahil"
}
output "instances" {
 value       = aws_instance.example_server.public_ip
 description = "EC2 details"
}
