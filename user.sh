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


curl -sL https://rpm.nodesource.com/setup_lts.x | bash >>$logfiles

validate $? "Setup NodeJS repos"


yum install nodejs -y >>$logfiles

validate $? "Install NodeJS"

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


curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>>$logfiles

validate $? "Download the application code to created app directory"


cd /app  >>$logfiles




unzip /tmp/cart.zip -y &>>$logfiles



cd /app &>>$logfiles




npm install &>>$logfiles

validate $? "Download the dependencies."


cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$logfiles

validate $? "Setup SystemD Cart Service"


systemctl daemon-reload &>>$logfiles

validate $? "Load the service"


systemctl enable user &>>$logfiles

validate $? "enable the service"


systemctl start user &>>$logfiles

validate $? "Start the service."


cp /home/centos/roboshop-shell/mongoshell.repo /etc/yum.repos.d/mongo.repo &>>$logfiles

validate $? "setup MongoDB repo client "


yum install mongodb-org-shell -y &>>$logfiles

validate $? "install mongodb-client"


mongo --host mongodb.saikiransudhireddy.com  </app/schema/catalogue.js &>>$logfiles

validate $? "Load Schema"

echo "done"

validate $? "Setup is Successfull"



