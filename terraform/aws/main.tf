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

resource "aws_s3_bucket" "videos" {
  # bucket = "${var.bucket_name}-${formatdate("YYYYMMDDhhmm", timestamp())}"
  bucket = var.bucket_name
  tags   = {Description = "YC-resilio-videos"}
}

resource "aws_instance" "silioSync" {
  ami = var.ami_freetier["amazon-linux"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_test_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    sudo mkdir /mnt/s3
    sudo amazon-linux-extras install docker epel -y
    sudo yum update -y
    sudo yum install -y s3fs-fuse
    sudo systemctl start docker
    sudo usermod -a -G docker ec2-user
    sudo echo "${var.aws_access_key}:${var.aws_secret_key}" > /home/ec2-user/.passwd-s3fs
    sudo chmod 600 /home/ec2-user/.passwd-s3fs
    sudo s3fs ${var.bucket_name} /mnt/s3 -o passwd_file=/home/ec2-user/.passwd-s3fs,nonempty,rw,allow_other,mp_umask=002,uid=1000,gid=1000
    sleep 30
    sudo docker run -d --name silio-sync -p 8888:8888 -p 55555:55555 -v /mnt/s3:/mnt/sync --restart always resilio/sync
  EOF

  tags = {
    Name = "silioSyncTemp"
  }
  security_groups = [aws_security_group.resilio-web.name] # not aws_security_group.resilio-web.id
}

resource "aws_instance" "streamlit" {
  ami = var.ami_freetier["rhel"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_test_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install docker git -y
    # sudo systemctl start docker
    # sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    git clone https://github.com/cmskzhan/helloworld.git /home/ec2-user/github
  EOF

  tags = {
    Name = "A simple streamlit app"
  }
  security_groups = [aws_security_group.resilio-web.name] # not aws_security_group.resilio-web.id
}

output "ssh_command" {
  value = "ssh ec2-user@${aws_instance.streamlit.public_ip}"
}