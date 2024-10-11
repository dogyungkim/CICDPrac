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
  region = "ap-northeast-2"
}

module "vpc" {
  source               = "./vpc"
  vpc_cidr             = "192.168.0.0/16"
  environment          = "dev"
  public_subnet_count  = 1
  private_subnet_count = 1
}

module "ec2" {
  source          = "./ec2"
  ami_image       = "ami-05d768df76a2b8bd8"
  tags            = "personal-dev"
  instance_count  = 1
  private_ips     = ["192.168.0.43"]
  security_groups = [aws_security_group.personal-dev-sg-basic.id]
  subnets         = [module.vpc.public_subnet_ids[0]]
}

resource "aws_security_group" "personal-dev-sg-basic" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "personal-dev"
  }
}