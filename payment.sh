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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE "Installing Python 3.6"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE "downloading the shipping file"

cd /app &>> $LOGFILE

VALIDATE "moving to app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE "unzipping shipping zip file"

pip3.6 install -r requirements.txt&>> $LOGFILE

VALIDATE "Installing dependencies"

cp /home/centos/Roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE "Copying payment service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE "Reloading payment daemon"

systemctl enable payment &>> $LOGFILE

VALIDATE "Enabling payment service"

systemctl start payment &>> $LOGFILE

VALIDATE "Starting payment service"

