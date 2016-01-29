#echo "Downloading and installing kafka-mesos-0.9.4.0"
#wget http://maven.big-data-europe.eu/nexus/content/repositories/thirdparty/org/apache/kafka/kafka-mesos/0.9.4.0/kafka-mesos-0.9.4.0-distribution.zip
#mkdir -p /usr/local/kafka-mesos/kafka-mesos-0.9.4.0
#ln -s /usr/local/kafka-mesos/kafka-mesos-0.9.4.0 /usr/local/kafka-mesos/current
#unzip kafka-mesos-0.9.4.0-distribution.zip -d /usr/local/kafka-mesos/kafka-mesos-0.9.4.0/
#echo "Consult /usr/local/kafka-mesos/kafka-mesos-0.9.4.0/README for setting up and running kafka on mesos"

FROM mesosphere/mesos:0.26.0-0.2.145.ubuntu1404

RUN apt-get install -y wget unzip

RUN wget http://maven.big-data-europe.eu/nexus/content/repositories/thirdparty/org/apache/kafka/kafka-mesos/0.9.4.0/kafka-mesos-0.9.4.0-distribution.zip

RUN mkdir -p /usr/local/kafka-mesos/kafka-mesos-0.9.4.0

RUN ln -s /usr/local/kafka-mesos/kafka-mesos-0.9.4.0 /usr/local/kafka-mesos/current

RUN unzip kafka-mesos-0.9.4.0-distribution.zip -d /usr/local/kafka-mesos/kafka-mesos-0.9.4.0/

ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos.so
WORKDIR /usr/local/kafka-mesos/current
EXPOSE 7000
