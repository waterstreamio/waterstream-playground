#!/bin/sh

docker run -it --network=waterstream-playground --name ksql-shell --rm confluentinc/ksqldb-cli ksql http://ksqldb:8088
