FROM openjdk:8-alpine

MAINTAINER Juergen Jakobitsch <jakobitschj@semantic-web.at>
MAINTAINER Gezim Sejdiu <g.sejdiu@gmail.com>

ENV SCALA_VERSION=2.11
ENV KAFKA_VERSION=0.11.0.1

RUN apk add --update unzip wget curl bash python3 && rm -rf /var/cache/apk/*


ADD download-kafka.sh /tmp/download-kafka.sh
RUN mkdir -p /usr/local/apache-kafka

RUN chmod a+x /tmp/download-kafka.sh && \
    sync && /tmp/download-kafka.sh && \
    tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /usr/local/apache-kafka/ && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    ln -s /usr/local/apache-kafka/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /usr/local/apache-kafka/current

COPY wait-for-step.sh /
COPY execute-step.sh /
COPY finish-step.sh /

RUN ln -s /usr/local/apache-kafka/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /app
RUN ln -s /usr/local/apache-kafka/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/config /config

ADD kafka-bin.py /app/bin/
ADD kafka-init /app/bin/
