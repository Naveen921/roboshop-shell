#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/temp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied repo to yum.repos.d"

yum install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installed"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Updated"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarted"