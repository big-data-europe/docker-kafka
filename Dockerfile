FROM openjdk:8-alpine

MAINTAINER Juergen Jakobitsch <jakobitschj@semantic-web.at>
MAINTAINER Gezim Sejdiu <g.sejdiu@gmail.com>

ENV SCALA_VERSION=2.11
ENV KAFKA_VERSION=0.10.2.0

RUN apk upgrade
RUN apk add --update bash python3 && rm -rf /var/cache/apk/*

RUN apt-get update && \
rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    wget -q http://apache.mirrors.spacedump.net/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -O /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /usr/local/apache-kafka/ && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN ln -s /usr/local/apache-kafka/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /usr/local/apache-kafka/current

COPY wait-for-step.sh /
COPY execute-step.sh /
COPY finish-step.sh /

RUN ln -s /usr/local/apache-kafka/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /app
RUN ln -s /usr/local/apache-kafka/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/config /config

ADD kafka-bin.py /app/bin/
ADD kafka-init /app/bin/
