#!/bin/bash
echo "make sure you have sudo permission!"
echo "1. update yum"
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum -y update
  sudo yum -y upgrade
echo "2. upgrade python"
  sudo dnf groupinstall -y 'development tools'
  sudo yum remove -y python3  #old 3.6 default version
  sudo yum install -y python3.9
echo "3. install docker"
  sudo yum install -y docker-ce docker-ce-cli containerd.io --allowerasing
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
  pip3 install docker-compose
echo "4. add streamlit, pandas"  
  python -m pip install --upgrade pip
  pip3 install streamlit
echo "5. install AWS cli"
  pip3 install awscli --upgrade
echo "test docker by logging out/in and run  sudo docker run hello-world"
