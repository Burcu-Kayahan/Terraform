sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo service docker start                    
docker run -p 8080:80 nginx