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
  # profile = "temp1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "resilio-web" {
  name        = "resilio-web"
  description = "Allow web traffic"
   ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_key_pair" "tf_test_key" {
  key_name   = "tf_test_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "silioSync" {
  ami = var.ami_freetier["amazon-linux"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_test_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -a -G docker ec2-user
    sudo docker run -d --name silio-sync -p 8888:8888 -p 55555:55555 --restart always resilio/sync
  EOF

  tags = {
    Name = "silioSyncTemp"
  }
  security_groups = [aws_security_group.resilio-web.name] # not aws_security_group.resilio-web.id
}

resource "aws_s3_bucket" "videos" {
  bucket = "${var.bucket_name}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  tags   = {Description = "YC-resilio-videos"}
}

output "ssh_command" {
  value = "ssh ec2-user@${aws_instance.silioSync.public_ip}"
}