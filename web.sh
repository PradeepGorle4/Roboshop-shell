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

dnf install nginx -y

systemctl enable nginx

systemctl start nginx

rm -rf /usr/share/nginx/html/*

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

cd /usr/share/nginx/html

unzip /tmp/web.zip

cp /home/centos/Roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf

systemctl restart nginx 