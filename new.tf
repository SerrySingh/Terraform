terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "project" {
  type    = string
  default = "Netflix"
}

variable "owner" {
  type    = string
  default = "Pardhuman ji"
}

variable "env" {
  type    = string
  default = "dev"
}

resource "aws_vpc" "some_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = format("%s_%s_%s", var.project, "vpc", var.env)
    Environment = var.env
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_subnet" "some_public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = format("%s_%s_%s", var.project, "pub-sn", var.env)
    Environment = var.env
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.some_custom_vpc.id

  tags = {
    Name        = format("%s_%s_%s", var.project, "IGW", var.env)
    Environment = var.env
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.some_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name        = format("%s_%s_%s", var.project, "RT", var.env)
    Environment = var.env
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.some_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "web_instance" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "sahil"

  subnet_id                   = aws_subnet.some_public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name        = format("%s_%s_%s", var.project, "instance", var.env)
    Environment = var.env
    Owner       = var.owner
    Project     = var.project
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

output "new_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "public_ip" {
  value = aws_instance.web_instance.public_ip
}
