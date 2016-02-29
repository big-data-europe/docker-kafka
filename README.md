# Kafka docker

Docker image containing a standard Kafka distribution.

Versions used in this docker image:
* Scala Version: 2.11
* Kafka Version: 0.9.0.1
* Java 1.8.0_72

Image details:
* Installation directory: /usr/local/apache-kafka/current

## Kafka Docker image

To start Kafka Docker image:

    docker run -i -t bde2020/docker-kafka /bin/bash

To start a Kafka Server inside this Docker image
* update at least zookeeper.connect in /usr/local/apache-kafka/current/config/server.properties to point to your zookeeper installation. a chroot can be used and will be created upon startup, e.g. zookeeper.connect=192.168.88.219:2181,192.168.88.220:2181/kafka
* run the following commands
  cd /usr/local/apache-kafka/current
  ./bin/kafka-start-server.sh ./config/server.properties
