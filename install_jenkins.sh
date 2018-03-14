#!/bin/bash

## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
#source /root/scripts/common-functions.sh
source /tmp/common-functions.sh

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

### Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins java -y &>/dev/null
Stat $? "Installing Jenkins"
systemctl enable jenkins &>/dev/null
systemctl start jenkins
Stat $? "Starting Jenkins"
systemctl stop jenkins

sed -i -e '/isSetupComplete/ s/false/true/' -e '/name/ s/NEW/RUNNING/' /var/lib/jenkins/config.xml 
curl -s https://raw.githubusercontent.com/linuxautomations/jenkins/master/admin.xml >/var/lib/jenkins/users/admin/config.xml
chown jenkins:jenkins /var/lib/jenkins/users/admin/config.xml
systemctl start jenkins
Stat $? "Configuring Jenkins"
