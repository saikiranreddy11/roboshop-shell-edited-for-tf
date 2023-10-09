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

yum install maven -y  &>>$logfiles

validate $? "installing maven"

id roboshop &>>$logfiles

if [ $? -ne 0 ]
then
    useradd roboshop &>>$logfiles
    validate $? "Adding application User"
fi

test -d /app
if [ $? -ne 0 ]
then
    mkdir /app &>>$logfiles
    validate $? "setup an app directory"
fi

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$logfiles

validate $? "importing shipping files"

cd /app &>>$logfiles



unzip -o /tmp/shipping.zip &>>$logfiles

validate $? "unzipping the shipping"

cd /app &>>$logfiles

mvn clean package &>>$logfiles

validate $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>>$logfiles

validate $? "moving shipping.jar"

cp /home/centos/roboshop-shell-edited-for-tf/shipping.service /etc/systemd/system/shipping.service &>>$logfiles

validate $? "copying the configuration"

systemctl daemon-reload &>>$logfiles

validate $? "reloading the configuration"



systemctl enable shipping  &>>$logfiles

validate $? "enabling shipping"

systemctl restart shipping &>>$logfiles

validate $? "starting shipping"

yum install mysql -y &>>$logfiles

validate $? "installing mysql"

mysql -h mysql.saikiransudhireddy.com -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$logfiles

validate $? "loading the schema"

systemctl restart shipping &>>$logfiles

validate $? "restarting the shipping"
