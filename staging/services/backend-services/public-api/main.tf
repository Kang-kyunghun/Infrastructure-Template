provider "aws" {
  region  = "ap-northeast-2"
  profile = "jack"
}

data "terraform_remote_state" "staging_vpc" {
  backend = "local"

  config = {
    path = "../../../vpc/terraform.tfstate"
  }
}

resource "aws_security_group" "public_api" {
  vpc_id      = data.terraform_remote_state.staging_vpc.outputs.staging_vpc_id
  name        = "Public API EC2 Security Group"
  description = "Public API EC2 Security Group"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public API EC2 Security Group"
  }
}

resource "aws_instance" "public_api" {
  ami                    = "ami-0d19691dd2d866cb6"
  instance_type          = "t2.micro"
  key_name               = "terraform-tamplate-public-api"
  vpc_security_group_ids = [aws_security_group.public_api.id]
  subnet_id              = data.terraform_remote_state.staging_vpc.outputs.staging_public_subnet_id

  tags = {
    Name = "public-api"
  }
}