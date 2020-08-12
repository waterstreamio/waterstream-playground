# waterstream-playground

Local demo environment for Waterstream. Requires a license for Waterstream to run.

## Prerequisited:

- Docker

- `docker-compose`

- `bash`

## How to run 


First of all you need Waterstream license file `waterstream.license` - place it in the project root folder. 
You'll also need Dockerhub credentials - ask SimpleMatter representative to get them, then log into Dockerhub:

    docker login -u <..username..> 
    ... enter the DockerHub password here. 

Now run the script that copies default configs, creates the network and runs the containers:

    ./startPlayground.sh
     
This includes:

- ZK+Kafka
- Waterstream - MQTT port 1883, monitoring port 1884
- Prometheus - port 9090, no authentication
- Grafana - port 3000, default username/password is admin/admin, prompted to change it after the first login.
Read-only user user1/password1 is also provisioned.
Waterstream dashboard is provisioned in the default organization. Anonymous org is created and it has 
the Prometheus datasource, but no dashboards - it has to be uploaded manually if anonymous dashboard is needed.
Also default dashboard has to be set manually.
Volume is configured for Grafana data so that the changes performed via UI survive container restarts 
(including `docker-compose down`)
- ksqlDB - port 8088

To stop:

    ./stopPlayground.sh

## Configuration

After running `startPlayground.sh` you'll have `.env`, `authorization.csv` and `user.properties` files 
in the project folder. You can edit them and then restart the playground to apply the changes: 

    ./stopPlayground.sh
    ./startPlayground.sh
 
## Sample commands

### Kafka

`exec` into Kafka container to be able to run the commands:

    docker exec -ti ws-playground-zookeeper /bin/bash

or: 
    
    docker exec -ti ws-playground-zookeeper /bin/bash
    export KAFKA_OPTS="" #Reset JVM agent settings

List Kafka topics:

    kafka-topics --list --zookeeper zookeeper:2181
    
Display all messages in Kafka default MQTT messages topic from the beginning:
    
    kafka-console-consumer --from-beginning --bootstrap-server kafka:9092 --topic mqtt_messages --property print.key=true

Display messages in Kafka default MQTT message topic starting from now:    

    kafka-console-consumer --bootstrap-server kafka:9092 --topic mqtt_messages --property print.key=true
    
    kafka-console-consumer --bootstrap-server kafka:9092 --topic waterstream_demo_1 --property print.key=true
    
Send a message from console to Kafka default MQTT messages topic, use colon (`:`)  as separator between key 
(which contains MQTT topic name) and values (which contains MQTT message body):
    
    kafka-console-producer --broker-list kafka:9092 --topic mqtt_messages --property "parse.key=true" --property "key.separator=:"

### Mosquitto client 

Make sure you don't run 2 commands with same client id (`-i` parameter) at the same time - otherwise
one of them will drop connection, as per MQTT specification requirements.

Listen to the messages on all MQTT topics, use QoS 0 for subscription:

    mosquitto_sub -h localhost -p 1883 -t "#" -i mosquitto_1 -q 0
    
Same with MQTT topic name: 

    mosquitto_sub -h localhost -p 1883 -t "#" -i mosquitto_1 -q 0 -v
    
Listen to the messages on MQTT topic "sample_topic", use QoS 1 for subscription: 

    mosquitto_sub -h localhost -p 1883 -t "sample_topic" -i mosquitto_1 -q 1 
   
Send "Hello, world!" message to "sample_topic" topic with QoS0:

    mosquitto_pub -h localhost -p 1883 -t "sample_topic" -i mosquitto_2 -q 0 -m "Hello, world!" 
    
Send messages to "sample_topic" with QoS 0, each line is a separate message:

    mosquitto_pub -h localhost -p 1883 -t "sample_topic" -i mosquitto_2 -q 0 -l 
    
Send from stdin to "sample_topic" with QoS 1, entire content is a single message: 

    mosquitto_pub -h localhost -p 1883 -t "sample_topic" -i mosquitto_2 -q 1 -s 


### ksqlDB examples

Run `./ksqlShell.sh` to open ksql console. Create stream:

    CREATE STREAM sample_data (NAME STRING, VALUE INT) 
    WITH (KAFKA_TOPIC = 'waterstream_demo_1', VALUE_FORMAT = 'DELIMITED');

Show messages as they arrive:

    select * from sample_data emit changes;

Send sample message:

    mosquitto_pub -h localhost -p 1883 -t "waterstream-demo-1/dev1" -i mosquitto_2 -q 0 -m "hello,1234"
    
To map the response topics to MQTT change `MESSAGES_TOPICS_PATTERNS` in `.env`.

