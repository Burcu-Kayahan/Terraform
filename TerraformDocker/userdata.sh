#!bin/bash
yum update -y && yum install -y docker
systemctl start docker
usermod -aG docker ec2-user
docker run -p 80:80 nginx:alpine