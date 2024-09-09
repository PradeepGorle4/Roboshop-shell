#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$R ERROR:: $1....FAILED $N"
        exit 1
    else
        echo -e "$G $1....SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR : you are not root user, run the script with sudo access $N"
    exit 1
else
    echo -e "$G You are root user $N" 
fi

dnf module disable mysql -y &>> $LOGFILE

VALIDATE "Disabling default mysql server version as it is mysql 8"

cp /home/centos/Roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE "Copying the mysql.repo file to yum.repos.d"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE "Installing mysql server:5.7"

systemctl enable mysqld &>> $LOGFILE

VALIDATE "Enabling mysql service"

systemctl start mysqld &>> $LOGFILE

VALIDATE "Starting mysql service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE "chainging the default password"

mysql -uroot -pRoboShop@1 &>> $LOGFILE

VALIDATE "Verifying new password"