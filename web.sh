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

dnf install nginx -y &>> $LOGFILE

VALIDATE "Installing Nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE "Enabling Nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE "Deleting default html web content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE "Downloading the web file"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE "changing to html /usr/share/nginx/html directory"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE "Unzipping web files"

cp /home/centos/Roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE "Copying roboshop reverse proxy file"

systemctl restart nginx &>> $LOGFILE

VALIDATE "Restarting Nginx service"
