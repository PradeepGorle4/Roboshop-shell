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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE "Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE "Downloading rabbitmq script"

dnf install rabbitmq-server -y &>> $LOGFILE

VALIDATE "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE "Enabling RabbitMQ service"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE "Starting RabbitMQ service"

id roboshop

if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
    VALIDATE "creating a new user roboshop"
else
    echo -e "roboshop user already exists.... $Y skipping it $N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE "setting permissions"