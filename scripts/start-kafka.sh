#!/bin/bash

cd $KAFKA_HOME

if [ "$MODE" == "zookeeper" ];
then
    ./bin/zookeeper-server-start.sh config/zookeeper.properties

elif [ "$MODE" == "kafka" ];
then

    sed -e "s|{{KAFKA_ADVERTISED_LISTENERS}}|${KAFKA_ADVERTISED_LISTENERS:-PLAINTEXT://:9092}|g" \
    -e "s|{{KAFKA_AUTO_CREATE_TOPICS_ENABLE}}|${KAFKA_AUTO_CREATE_TOPICS_ENABLE:-true}|g" \
    -e "s|{{KAFKA_DEFAULT_REPLICATION_FACTOR}}|${KAFKA_DEFAULT_REPLICATION_FACTOR:-1}|g" \
    -e "s|{{KAFKA_LISTENERS}}|${KAFKA_LISTENERS:-PLAINTEXT://:9092}|g" \
    -e "s|{{KAFKA_LISTENER_SECURITY_PROTOCOL_MAP}}|${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:-PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL}|g" \
    -e "s|{{KAFKA_LOG_DIRS}}|${KAFKA_LOG_DIRS:-/tmp/kafka-logs}|g" \
    -e "s|{{KAFKA_LOG_CLEANUP_POLICY}}|${KAFKA_LOG_CLEANUP_POLICY:-delete}|g" \
    -e "s|{{KAFKA_NUM_PARTITIONS}}|${KAFKA_NUM_PARTITIONS:-1}|g" \
    -e "s|{{KAFKA_LOG_RETENTION_HOURS}}|${KAFKA_LOG_RETENTION_HOURS:-168}|g" \
    -e "s|{{KAFKA_ZOOKEEPER_CONNECT}}|${KAFKA_ZOOKEEPER_CONNECT}|g" \
    config/server.properties.template > config/server.properties

    ./bin/kafka-server-start.sh config/server.properties 

else
    echo "Undefined workload type $MODE. Please specify one of those: zookeeper, kafka"
fi