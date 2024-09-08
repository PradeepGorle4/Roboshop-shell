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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE "downloading the roboshop file"

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE "Unzipping cart"

npm install &>> $LOGFILE

VALIDATE "Installing NodeJS dependencies"

cp /home/centos/Roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE "Reloading cart daemon"

systemctl enable cart &>> $LOGFILE

VALIDATE "Enabling cart service"

systemctl start cart &>> $LOGFILE

VALIDATE "Starting cart service"
