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

* Create a Marathon Application Setup in json like the one below and store it in a file (e.g. marathon-kafka.json)

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
* note that the above example configures the docker image to run network in bridge mode resulting in the fact that Kafka brokers will allways (also after restart) be available at host.url:9092. for this to work properly it is necessary to override advertised.host.name and advertised.host.port in the Kafka Server startup command. If the above json is run inside marathon on http://bigdata-one.example.com:8080 the Kafka broker will be available at http://bigdata-one.example.com:9092.
