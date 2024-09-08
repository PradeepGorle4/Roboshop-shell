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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE "Installing redis repo file"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE "Enabling redis 6.2"

dnf install redis -y &>> $LOGFILE

VALIDATE "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE

systemctl enable redis &>> $LOGFILE

VALIDATE "Enabling redis service"

systemctl start redis &>> $LOGFILE

VALIDATE "Starting redis service"



