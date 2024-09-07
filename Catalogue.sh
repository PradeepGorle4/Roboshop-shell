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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE "Disabling Current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE "Enabling NodeJS:18" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE "Installing Node JS 18"

useradd roboshop &>> $LOGFILE
VALIDATE "Creating roboshop user"

mkdir /app &>> $LOGFILE
VALIDATE "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE "Downloading the catalog package"

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE "UnZipping catalogue"

npm install &>> $LOGFILE
VALIDATE "Installing NodeJS Dependencies"

# Always use absolute path to avoid confusion.
cp /home/centos/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE "Copying catalogue.service file" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE "Reloading Catalogue daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE "Enabling Catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE "Starting Catalogue"

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE "Copying mongo.repo to yum.repos.d"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE "Installing Mongodb client"

mongo --host mongodb.pradeepdevops.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE "Loading Catalogue data into MongoDB"

#END
