#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo mkfs -t ext4 /dev/sdh
sudo mkdir /mnt/jenkins
sudo mount /dev/sdh /mnt/jenkins
sudo sed -i '$ a /dev/sdh    /mnt/jenkins ext4   defaults    0    0' /etc/fstab
sudo docker run -u root --rm -d -p 8080:8080 -p 50000:50000 -v /mnt/jenkins:/mnt/jenkins -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean
/bin/sleep 45
ID=`sudo docker container ls -q`
PASS=`sudo docker container exec -t $ID cat /var/jenkins_home/secrets/initialAdminPassword`
aws ssm put-parameter --name 'jenkins/initial_password' --type "SecureString" --value $PASS --region us-east-1 --overwrite