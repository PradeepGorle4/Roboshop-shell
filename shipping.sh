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

dnf install maven -y &>> $LOGFILE

VALIDATE "Installing Maven which is a Java Package manager, so it takes care of installing java"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE "downloading the shipping file"

cd /app &>> $LOGFILE

VALIDATE "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE "unzipping shipping zip file"

mvn clean package &>> $LOGFILE

VALIDATE "downloading dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE "renaming shipping jar file"

cp /home/centos/Roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE "Copying shipping service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE "Reloading shipping daemon"

systemctl enable shipping &>> $LOGFILE

VALIDATE "Enabling shipping service"

systemctl start shipping &>> $LOGFILE

VALIDATE "Starting shipping service"

dnf install mysql -y &>> $LOGFILE

VALIDATE "Installing mysql client to load the schema"

mysql -h mysql.pradeepdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE "loading schema"

systemctl restart shipping &>> $LOGFILE

VALIDATE "restarting shipping service"