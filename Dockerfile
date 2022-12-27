FROM eclipse-temurin:11 AS builder

RUN apt-get update

FROM builder AS kafka

ENV SCALA_VERSION=2.13
ENV KAFKA_VERSION=3.2.2
ENV KAFKA_HOME=/opt/kafka 

RUN wget -O apache-kafka.tgz "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" && \
    mkdir -p ${KAFKA_HOME} && \
    tar -xf apache-kafka.tgz -C ${KAFKA_HOME} --strip-components=1 && \
    rm apache-kafka.tgz

WORKDIR ${KAFKA_HOME}

COPY ./config/kafka ${KAFKA_HOME}/config
COPY ./scripts/start-kafka.sh /

CMD ["/bin/bash", "/start-kafka.sh"]

FROM builder AS ksql

ENV KSQL_MAJOR_VERSION=0.28
ENV KSQL_PATCH_VERSION=2
ENV KSQL_HOME=/opt/ksql

RUN wget -O ksql.tar.gz "http://ksqldb-packages.s3.amazonaws.com/archive/${KSQL_MAJOR_VERSION}/confluent-ksqldb-${KSQL_MAJOR_VERSION}.${KSQL_PATCH_VERSION}.tar.gz" && \
    mkdir -p ${KSQL_HOME} && \
    tar -xf ksql.tar.gz -C ${KSQL_HOME} --strip-components=1 && \
    rm ksql.tar.gz

WORKDIR ${KSQL_HOME}

COPY ./config/ksql ${KSQL_HOME}/etc/ksqldb
COPY ./scripts/start-ksql.sh /

CMD ["/bin/bash", "/start-ksql.sh"]

FROM builder AS pinot

ENV PINOT_VERSION=0.11.0
ENV PINOT_HOME=/opt/pinot 

RUN wget -O apache-pinot.tgz "https://archive.apache.org/dist/pinot/apache-pinot-${PINOT_VERSION}/apache-pinot-${PINOT_VERSION}-bin.tar.gz" && \
    mkdir -p ${PINOT_HOME} && \
    tar -xf apache-pinot.tgz -C ${PINOT_HOME} --strip-components=1 && \
    rm apache-pinot.tgz

WORKDIR ${PINOT_HOME}

COPY ./scripts/start-pinot.sh /

CMD ["/bin/bash", "/start-pinot.sh"]

FROM flink:1.16.0 AS flink

ENV FLINK_VERSION=1.16.0

RUN wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/${FLINK_VERSION}/flink-sql-connector-kafka-${FLINK_VERSION}.jar