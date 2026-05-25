provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3 .0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "web-server"

  ami = "ami-02dd44faa40720bb8"
  instance_type = "t3.medium"

  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  key_name = "devops-key"

}
