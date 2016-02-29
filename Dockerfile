FROM ubuntu:trusty

MAINTAINER Juergen Jakobitsch <jakobitschj@semantic-web.at>

RUN apt-get install -y wget unzip software-properties-common vim lsof

RUN  add-apt-repository -y ppa:webupd8team/java
RUN  apt-get update
RUN  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN  apt-get -y install oracle-java8-installer
RUN  apt-get -y install oracle-java8-set-default

RUN /bin/bash -c "source /etc/profile.d/jdk.sh"

RUN rm -f /var/cache/oracle-jdk8-installer/jdk-8u72-linux-x64.tar.gz

ADD kafka_2.11-0.9.0.1.tgz /usr/local/apache-kafka/

RUN ln -s /usr/local/apache-kafka/kafka_2.11-0.9.0.1 /usr/local/apache-kafka/current

RUN rm -f /tmp/kafka_2.11-0.9.0.1.tgz
