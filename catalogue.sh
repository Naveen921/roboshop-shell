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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGSDIR
VALIDATE $? "Settingup NPM source"

yum install nodejs -y &>>$LOGSDIR
VALIDATE $? "Installing Nodejs"

#once the user is created, if you run this script 2nd time this command will defintely fail
#IMPROVEMENT: first check the user already exist or not, then create
useradd roboshop &>>$LOGSDIR

#write a condition to check directory already exist or not
mkdir /app &>>$LOGSDIR

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGSDIR
VALIDATE $? " downloading catalogue artifact"

cd /app &>>$LOGSDIR
VALIDATE $? "Moving into APP directory" 

unzip /tmp/catalogue.zip &>>$LOGSDIR
VALIDATE $? "unzipping catalogue"

npm install &>>$LOGSDIR
VALIDATE $? "installing dependencies"

# give full path of catalogue.service because we are inside /app
cp home/centos/roboshop-shell/catlogue.service  /etc/systemd/system/catalogue.service &>>$LOGSDIR
VALIDATE $? "copying catalogue service"

systemctl daemon-reload &>>$LOGSDIR
VALIDATE $? "daemon reload catalogue"

systemctl enable catalogue &>>$LOGSDIR
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOGSDIR
VALIDATE $? "starting catalogue"

cp home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGSDIR
VALIDATE $? "copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGSDIR
VALIDATE $? "installing mongo client"

mongo --host mongodb.joindevops.click </app/schema/catalogue.js &>>$LOGSDIR
VALIDATE $? "loading catalouge into mongo"