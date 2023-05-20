terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "resilio-web" {
  name        = "resilio-web"
  description = "Allow web traffic"
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 55555 # Listening port for Sync traffic 
    to_port     = 55555 # you can change it, but in this case change it in Sync settings as well
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "silioSync" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  tags = {
    Name = "silioSyncTemp"
  }
  security_groups = [aws_security_group.resilio-web.id] # aws_security_group.resilio-web.name?
}

resource "aws_s3_bucket" "videos" {
  bucket = formatdate("resilio-sync-videos-%Y%m%d%H%M%S", timestamp())
  tags   = {Description = "YC-resilio-videos"}
}
