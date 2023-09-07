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


curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$logfiles

validate $? "Configure YUM Repos from the script provided by vendor"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$logfiles

validate $? "Configure YUM Repos for RabbitMQ."

yum install rabbitmq-server -y &>>$logfiles

validate $? "Install RabbitMQ"

systemctl enable rabbitmq-server &>>$logfiles



systemctl start rabbitmq-server &>>$logfiles
validate $? "Start RabbitMQ Service"


sudo rabbitmqctl list_users | awk '{print $1}' | grep  "roboshop" &>>$logfiles

if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop roboshop123 &>>$logfiles
    validate $? "Adding a user roboshop"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$logfiles

validate $? "Setting the permissions for the user"

