#!/bin/bash
sudo yum update -y

#install jenkins
sudo yum install java-21-amazon-corretto -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo yum install jenkins -y
sudo systemctl enable --now jenkins
systemctl start jenkins

#install trivy
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF
sudo yum install trivy -y

#install docker
sudo yum install docker -y
sudo systemctl enable --now docker
systemctl start docker
docker run -itd --name sonar -p 9000:9000 sonarqube:lts
sudo chmod 777 /var/run/docker.sock

#install kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

#update's kube_config
aws eks update-kubeconfig --region ${region} --name ${cluster_name}