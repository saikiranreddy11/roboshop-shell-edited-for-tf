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

yum module disable mysql -y >>$logfiles

validate $? "Disabling SQL"

cp sql.repo /etc/yum.repos.d/mysql.repo

validate $? "Copying the repo"

yum install mysql-community-server -y >>$logfiles

validate $? "Installing SQL"

systemctl enable mysqld >>$logfiles

validate $? "enabling SQL"

systemctl start mysqld >>$logfiles

validate $? "starting SQL"

mysql_secure_installation --set-root-pass RoboShop@1 >>$logfiles

validate $? "setting the password"

mysql -uroot -pRoboShop@1 