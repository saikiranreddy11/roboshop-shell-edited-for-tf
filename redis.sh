#!/bin/bash
id=$(id -u)
R="\e[31m"
N="\e[0m"
Y="\e[33m"
date=$(date +%F-%H-%M-%S)
script_name=$0
logfiles=/tmp/shell-script-logs/$script_name-$date.log 
if [ $id -ne 0 ]
then
    echo -e "$R ERROR: $N you do not have the sudo access, please install with root access"
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R  $2  is FAiled $N"
        exit 1
    else 
        echo -e "$Y $2 is success"
    fi
}


yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$logfiles

validate $? "configuring redis"

yum module enable redis:remi-6.2 -y &>>$logfiles

validate $? "enabling redis"

yum install redis -y &>>$logfiles

validate $? "Installing redis"

sed -i "s/127.0.0.1/0.0.0.0/" <<<vim /etc/redis.conf

validate $? "Changing the DNS" 

systemctl enable redis &>>$logfiles

validate $? "Enabling Redis"

systemctl start redis &>>$logfiles

validate $? "Starting Redis"