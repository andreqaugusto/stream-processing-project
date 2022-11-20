#!/bin/bash

cd $PINOT_HOME

if [ "$MODE" == "broker" ];
then

    ./bin/pinot-admin.sh StartBroker -zkAddress $ZOOKEEPER

elif [ "$MODE" == "controller" ];
then

    ./bin/pinot-admin.sh StartController -zkAddress $ZOOKEEPER -controllerPort $CONTROLLER_PORT

elif [ "$MODE" == "server" ];
then

    ./bin/pinot-admin.sh StartServer -zkAddress $ZOOKEEPER

else
    echo "Undefined workload type $MODE. Please specify one of those: broker, controller, server"
fi
