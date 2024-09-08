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

VALIDATE "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE "Enabling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE "Installing NodeJS"

id roboshop # Only create roboshop user if it does not exist. skip it if already exists

if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE "creating roboshop user"
else
    echo -e "roboshop user already exists.... $Y skipping it $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE "Creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE "downloading the roboshop file"

cd /app

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE "Unzipping user"

npm install &>> $LOGFILE

VALIDATE "Installing NodeJS dependencies"

cp /home/centos/Roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE "Reloading user daemon"

systemctl enable user &>> $LOGFILE

VALIDATE "Enabling user service"

systemctl start user &>> $LOGFILE

VALIDATE "Starting user service"

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $

VALIDATE "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE "Installing mongodb client to load the data"

mongo --host mongodb.pradeepdevops.online </app/schema/user.js &>> $LOGFILE

VALIDATE "Loading the data to MongoDB"