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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE "Copied mongodb repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE "Installing MongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE "Enabling MongoD service"

systemctl start mongod &>> $LOGFILE
VALIDATE "Starting Mongodb service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE "Remote access to MongoDB"

systemctl restart mongod &>> $LOGFILE
VALIDATE "Restarting Mongodb"