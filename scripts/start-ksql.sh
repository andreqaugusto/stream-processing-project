#!/bin/bash

cd $KSQL_HOME

if [ "$MODE" == "server" ];
then

    sed -e "s|{{KSQL_BOOTSTRAP_SERVERS}}|${KSQL_BOOTSTRAP_SERVERS:-localhost:9092}|g" \
    -e "s|{{KSQL_LISTENERS}}|${KSQL_LISTENERS:-http://0.0.0.0:8088}|g" \
    etc/ksqldb/ksql-server.properties.template > etc/ksqldb/ksql-server.properties

    ./bin/ksql-server-start etc/ksqldb/ksql-server.properties

elif [ "$MODE" == "cli" ];
then
    $KSQL_HOME/bin/ksql ${KSQL_SERVER}
else
    echo "Undefined workload type $MODE. Please specify one of those: server, cli"
fi
