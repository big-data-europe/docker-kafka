# Kafka docker

Docker images based on mesos/kafka [1] to:
* Setup a standalone Kafka Environment
* Setup a Kafka Cluster using Marathon 

Currently supported versions:
* Mesos Version: 0.26.0
* Kafka Scala Version: 2.10
* Kafka Version: 0.9.0.0
* Kafka Mesos Version: 0.9.4.0


## Kafka Mesos Image
To start Kafka Mesos Image:

    docker run -i -t bde2020/docker-kafka /bin/bash

Consult the README file in /usr/local/kafka-mesos/current/ to see all options to start the kafka scheduler and to learn about the Kafka Mesos Rest API.


## Kafka Mesos 
To start Kafka Mesos Scheduler with sample settings:
    
    docker run -i -t bde2020/docker-kafka /usr/local/kafka-mesos/current/kafka-mesos.sh scheduler --api=http://localhost:7000 --zk=192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/kafka --master=zk://192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/mesos --storage=zk:/mesos-kafka-scheduler

To start Kafka Mesos Scheduler via Marathon:

Create a Marathon Application Setup in json like the one below
```json
{
    "container": {
        "type": "DOCKER",
        "docker": {
            "network": "BRIDGE",
            "image": "bde2020/docker-kafka",
            "portMappings":[
                {
                "containerPort":7000,
                "hostPort":0,
                "protocol":"tcp"
                }
            ]
        }
    },
    "id":"kafka-mesos-scheduler",
    "cpus": 0.5,
    "mem": 256,
    "ports": [7000],
    "cmd": "/usr/local/kafka-mesos/current/kafka-mesos.sh scheduler --api=http://$HOSTNAME:7000 --zk=192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/kafka --master=zk://192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/mesos --storage=zk:/mesos-kafka-scheduler",
    "instances": 1,
    "constraints": [["hostname", "UNIQUE"]]
}
```
Store the above json in a file [ e.g. marathon-kafka.json ] and run the app 

    curl -X POST http://marathon.mesos.net:8080/v2/apps -d @./kafka-marathon-with-settings.json -H "content-type:application/json"

The scheduler REST API is now available under ${mesos.slave.host}:${marathon.assignedPort}/api. Consult the README file under /usr/local/kafka-mesos/current/README of the bde2020/docker-kafka docker image or visit https://github.com/mesos/kafka .
[1] https://github.com/mesos/kafka
