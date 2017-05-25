#!/bin/bash

# sleep in the below job is used for proper completion of the job and machine to return in stable state.
# starting the namenodes,nodemanger,resourcemanger, datanode etc.
start-all.sh 
echo
echo
echo
sleep 5
# starting the history server
mr-jobhistory-daemon.sh start historyserver
echo
echo
echo
sleep 5 
# if in safemode remove from the safemode.
hdfs dfsadmin -safemode leave; 
echo
echo
echo
sleep 5
echo --------------------------------------------------Executing the flume job------------------------------------------------------------------
# here first removing exsisting folder if there and then proceding for the execution of the flume job
hadoop fs -rm -r -skipTrash /project
hadoop fs -mkdir -p /project/flume_data/
flume-ng agent -n agent1 -c conf -f /home/chinmay/Desktop/projectagent.conf
echo ----------------------------------------------------End of the Flume job-------------------------------------------------------------------
echo
echo
echo
sleep 5
echo ----------------------------------------------------Converting xml filr to csv  -----------------------------------------------------------
# here first removing exsisting folder if there and then proceding for the execution of the converting  job
hadoop fs -rm -r -skipTrash /xmlfile
pig /home/chinmay/Desktop/projectxml.pig
echo ----------------------------------------------------End of Conversion----------------------------------------------------------------------
echo
echo
echo
sleep 5
echo -----------------------------------------------------Executing the first question----------------------------------------------------------
# here first removing exsisting folder if there and then proceding for the execution of the first question for 100% bpl completion job
hadoop fs -rm -r -skipTrash /bpl100pig
pig /home/chinmay/Desktop/pig100.pig
echo ---------------------------------------------------end of first question-------------------------------------------------------------------
echo
echo
echo
sleep 5
echo -----------------------------------------------------Executing the second question---------------------------------------------------------
# here first removing exsisting folder if there and then proceding for the execution of the first question for 80% bpl completion job
hadoop fs -rm -r -skipTrash /bpl100pig
pig /home/chinmay/Desktop/pig100.pig
echo ---------------------------------------------------end of second question------------------------------------------------------------------
echo
echo
echo
sleep 5
echo ---------------------------------------------------MySql table creation--------------------------------------------------------------------
# we are creating the mysql database and the tables for the ingestion of the data into MySqlbd
mysql -u root -pworkhard <<EOF
create database pigproject;
use pigproject;
create table bpl100(STATE varchar(100),DISTRICT varchar(100),TARGET varchar(100),ACHIEVED varchar(100),PERCENT varchar(100));
create table bpl80(STATE varchar(100),DISTRICT varchar(100),TARGET varchar(100),ACHIEVED varchar(100),PERCENT varchar(100));
EOF
echo ---------------------------------------------------MySql table creation Finished-----------------------------------------------------------
echo
echo
echo
sleep 5
echo ---------------------------------------------------putting values to mysqldb---------------------------------------------------------------
# using the sqoop job we are tarnsferring the data from hdfs to mysql db.
sqoop export --connect jdbc:mysql://localhost/pigproject --username root -P --table bpl100 --export-dir /bpl100pig/part-m-00000 --driver com.mysql.jdbc.Driver
sqoop export --connect jdbc:mysql://localhost/pigproject --username root -P --table bpl80 --export-dir /bpl80pig/part-m-00000 --driver com.mysql.jdbc.Driver
echo ---------------------------------------------------end of project--------------------------------------------------------------------------






