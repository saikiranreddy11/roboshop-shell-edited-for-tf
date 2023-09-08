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

yum install python36 gcc python3-devel -y >>$logfiles

id roboshop >>$logfiles

if [ $? -ne 0 ]
then
    useradd roboshop >>$logfiles
    validate $? "Adding application User"
fi 


test -d /app
if [ $? -ne 0 ]
then
    mkdir /app >>$logfiles
    validate $? "setup an app directory"
fi

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip >>$logfiles

validate $? "downloading the payment files"

cd /app >>$logfiles


unzip -o /tmp/payment.zip >>$logfiles

validate $? "unzipping the files"

cd /app >>$logfiles


pip3.6 install -r requirements.txt >>$logfiles

validate $? "installing the requirements"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service >>$logfiles

validate $? "copying the configuration"


