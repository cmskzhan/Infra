#!/bin/bash
echo "make sure you have sudo permission!"
echo "1. update yum"
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum update
  sudo yum upgrade
echo "2. upgrade python"
  sudo dnf groupinstall 'development tools'
  sudo yum remove python3  #old 3.6 default version
  sudo yum install python3.9
echo "3. install docker"
  sudo yum install docker-ce docker-ce-cli containerd.io --allowerasing
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
echo "4. install AWS cli"
  pip3 install awscli --upgrade --user
echo "test docker by logging out/in and run  sudo docker run hello-world"
