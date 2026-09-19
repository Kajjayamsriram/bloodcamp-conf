#!/bin/bash
sudo yum update -y

#install jenkins
sudo yum install java-21-amazon-corretto -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo yum install jenkins -y
sudo systemctl enable --now jenkins
systemctl start jenkins

#install docker
sudo yum install docker -y
docker run -itd --name sonar -p 9000:9000 sonarqube:lts


#install kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

#update's kube_config
aws eks update-kubeconfig --region ${region} --name ${cluster_name}