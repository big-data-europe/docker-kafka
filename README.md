# Kafka docker

Docker image containing a standard Kafka distribution.

Versions used in this docker image:
* Scala Version: 2.11
* Kafka Version: 0.9.0.1
* Java 1.8.0_72

Image details:
* Installation directory: /usr/local/apache-kafka/current

## Kafka Docker image

To start the Kafka Docker image:

    docker run -i -t bde2020/docker-kafka /bin/bash
    
To build the Kafka Docker image:

 ```bash
git clone https://github.com/big-data-europe/docker-kafka.git
docker build -t bde2020/docker-kafka .
```

To start a Kafka Server inside this Docker image
* update at least zookeeper.connect in /usr/local/apache-kafka/current/config/server.properties to point to your zookeeper installation. a chroot can be used and will be created upon startup, e.g. zookeeper.connect=192.168.88.219:2181,192.168.88.220:2181/kafka
* run the following commands

 ```bash
cd /usr/local/apache-kafka/current
./bin/kafka-start-server.sh ./config/server.properties
```

* note that it is possible to override any setting using the --override command line argument in case a hardcoded properties file is not desired.

 ```bash
cd /usr/local/apache-kafka/current
./bin/kafka-start-server.sh ./config/server.properties \
--override zookeeper.connect=192.168.88.219:2181,192.168.88.229:2181
```
* note that depending on the environment this image is used in, it might be necessary to change override advertised.host.name and override advertised.host.port parameter. this can be achieved with above --override command line argument. 
* for the complete documentation on available parameters refer to this document: http://kafka.apache.org/090/documentation.html#configuration

To start Kafka Docker image on Marathon:

* Create a Marathon Application Setup in json like the one below, store it in a file (e.g. marathon-kafka.json) and post it to Marathon's v2/app endpoint.

 ```json
 {
    "container": {
        "type": "DOCKER",
        "volumes": [
        {
                "containerPath": "/tmp/kafka-logs",
                "hostPath": "/var/lib/bde/kafka-logs",
                "mode": "RW"
        }
        ],
        "docker": {
            "network": "BRIDGE",
            "image": "bde2020/docker-kafka",
            "privileged":true,
            "portMappings": [
              { "containerPort": 9092, "hostPort": 9092}
            ]
        }
    },
    "id":"apache-kafka",
    "cpus": 0.2,
    "mem": 512,
    "cmd": "cd /usr/local/apache-kafka/current && ./bin/kafka-server-start.sh ./config/server.properties --override zookeeper.connect=192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/kafka --override delete.topic.enable=true --override advertised.host.name=$HOST --override advertised.port=$PORT0",
    "instances":1,
    "ports":[9092],
    "requirePorts":true,
    "constraints":[["hostname","UNIQUE",""]]
}
```

* note that 9092 is the default port for Kafka brokers. For the above example it is necessary that mesos is configured to use this port range. see http://mesos.apache.org/documentation/latest/attributes-resources/ for details. 
* note that in the above example Kafka's default log directory is mounted on the host. It is dependent on the specific use case if this is necessary or not.
* note that the above example configures the docker image to run network in bridge mode resulting in the fact that Kafka brokers will allways (also after restart) be available at host.url:9092. for this to work properly it is necessary to override advertised.host.name and advertised.host.port in the Kafka Server startup command. If the above json is run inside marathon on http://bigdata-one.example.com:8080 the Kafka broker will be available at http://bigdata-one.example.com:9092. If the Mesos cluster contained a second slave, e.g. http://bigdata-two.example.com, the second Kafka broker would be available as http://bigdata-two.example.com:9092 upon scaling in Marathon, resulting in a consistent and forseeable deployment.

To create a Kafka topic:

* note that the following example assumes that the Kafka Docker image is deployed using Marathon like above and scaled to three servers, bigdata-one.example.com, bigdata-two.example.com and (you guessed it) bigdata-three.example.com.
* log into the Kafka Docker image on one of these servers by issueing
 
 ```bash
docker ps
```

 on one of the hosts. This will expose the containerId of the running bde2020/docker-kafka container, e.g. 8b797c0d80b3.

 ```bash
docker exec -t -i 8b797c0d80b3 /bin/bash
```

 Inside the docker container cd into /usr/local/apache-kafka/current. Issue the following command to see available options for topic creation.

 ```bash
./bin/kafka-topics.sh --help
```

* note that the following options are required to create a topic: --zookeeper --partitions --replication-factor --topic --create. the below command creates a sample topic with 3 partitions and a replication-factor of one. note that the zookeeper url needs to be adapted to match the local installation. the zookeeper chroot is free to choose.

 ```bash
./bin/kafka-topics.sh --create --topic sampleTopic \
 --zookeeper 192.168.88.219:2181/kafka \ 
 --partitions 3 \
 --replication-factor 1
```

* the topic will now show up with the list topics command

 ```bash
./bin/kafka-topics.sh --list --zookeeper 192.168.88.219:2181/kafka
```

* kafka-console-producer.sh can be used to create some sample messages. start the producer by issueing the following command. note that this requires a running broker, which is available at the host's hostname and port 9092 if the above guidelines have been followed, the actual url of the Kafka broker needs to be adapted to the local environment.

 ```bash
./bin/kafka-console-producer.sh --topic sampleTopic --broker-list bigdata-one.example.com:9092
```

 After starting the producer simply type in some messages in the console and hit enter after every single message, we will consume these messages in the next step. Hit ctrl-c to stop the producer.
 
* kafka-console-consumer.sh can be used to consume messages. Issue the following command to consume the messages created in the previous step. Again update the zookeeper url and the bootstrap-server url to the local environment.
 
 ```bash
 ./bin/kafka-console-consumer.sh --topic sampleTopic \
  --zookeeper 192.168.88.219:2181/kafka \
  --bootstrap-server bigdata-one.example:9092 --from-beginning
```

* for further details on the above examples refer to http://kafka.apache.org/090/documentation.html#quickstart_createtopic
* note that you'll find Kafka's log directory on the hosting machines, if the Marathon setup from above has been used. checkout: /var/lib/bde/kafka-logs/ where there will be a directory like sampleTopic-{integer} depending on the partition the host has been assigned.
