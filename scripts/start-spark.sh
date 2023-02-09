#!/bin/bash

cd $SPARK_HOME/sbin 

if [ "$SPARK_MODE" == "master" ];
then

    ./start-master.sh

elif [ "$SPARK_MODE" == "worker" ];
then
    ./start-worker.sh $SPARK_MASTER_URL
else
    echo "Undefined workload type $SPARK_MODE. Please specify one of those: master, worker"
fi