#!/bin/bash
id=$(id -u)
R="\e[31m"
N="\e[0m"
Y="\e[33m"
date=$(date +%F-%H-%M-%S)
script_name=$0
#logfiles=/tmp/shell-script-logs/$script_name-$date.log 

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

test -d /tmp/shell-script-logs
if [ $? -ne 0 ]
then
    mkdir /tmp/shell-script-logs
    validate $? "setup an shell-script-log directory"
fi

logfiles=/tmp/shell-script-logs/$script_name-$date.log 

yum install nginx -y &>>$logfiles

validate $? "installing nginx "

systemctl enable nginx &>>$logfiles

validate $? "enabling nginx "

systemctl start nginx &>>$logfiles

validate $? "starting nginx "

rm -rf /usr/share/nginx/html/* &>>$logfiles

validate $? "removing nginx files "

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$logfiles

validate $? "copying web content "

cd /usr/share/nginx/html &>>$logfiles



unzip /tmp/web.zip &>>$logfiles

validate $? "unzipping the files "

cp /home/centos/roboshop-shell-edited-for-tf/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$logfiles

validate $? "copying configuration "

systemctl restart nginx &>>$logfiles

validate $? "restarting nginx "

