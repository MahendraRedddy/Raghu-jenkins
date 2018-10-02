#!/bin/bash

GITURL=https://github.com/cit31/jenkins.git
## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
#source /root/scripts/common-functions.sh
source /tmp/common-functions.sh

CheckRoot

if [ -f ~/.jenkinsinfo ]; then 
  source ~/.jenkinsinfo
else
  read -p 'Enter Jenkins Server IP Address: ' IP
  read -p 'Enter Username: ' username
  read -p 'Enter Password: ' password
  echo -e "IP=$IP\nusername=$username\npassword=$password" >~/.jenkinsinfo
fi

if [ -z "$IP" -o -z "$username" -o -z "$password"  ]; then 
  error -e "Please provide details properly !!"
  exit 1
fi

sudo yum install java git -y &>/dev/null
which java &>/dev/null
Stat $? "Java is configured"

if [ ! -f jenkins-cli.jar ]; then 
  wget -q http://$IP:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar
  Stat $? "Downloading Jenkins CLI"
fi 

java -jar ~/jenkins-cli.jar -auth $username:$password http://$IP:8080 list-jobs &>/dev/null
STAT=$?
Stat SKIP "Jenkins Connection"
if [ $STAT -ne 0 ]; then
  rm -f ~/.jenkinsinfo
  error "Provided Jenkins Username and Password is not working !!"
fi

cd /tmp	
rm -rf jenkins
git clone $GITURL &>/dev/null
cd jenkins
for job in `ls -1 jobs`; do 
  java -jar ~/jenkins-cli.jar -auth $username:$password http://$IP:8080 create-job $job <$job/config.xml
done


