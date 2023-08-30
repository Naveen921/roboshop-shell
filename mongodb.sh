#!/bin/bash

DATE=$(date +%F)
LOGSDIR=$LOGFILE/$0-$DATE.log
SCRIPT_NAME=$0
LOGFILE=/tmp

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
 then
    echo -e "$R ERROR:: Procced with ROOT access $N"
    exit 1
fi

VALIDATE(){
 if [ $1 -ne 0 ]
 then
    echo -e "$2 ....$R ERROR $N"
    exit 1
 else 
    echo -e "$2 ....$G SUCCESS $N"
   fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGSDIR
VALIDATE $? "copied repo to yum.repos.d"

yum install mongodb-org -y &>> $LOGSDIR
VALIDATE $? "Installed"

systemctl enable mongod &>> $LOGSDIR
VALIDATE $? "Enabled"

systemctl start mongod &>> $LOGSDIR
VALIDATE $? "Started"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGSDIR
VALIDATE $? "Updated"

systemctl restart mongod &>> $LOGSDIR
VALIDATE $? "Restarted"