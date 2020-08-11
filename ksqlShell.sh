#!/bin/sh


docker run -it --network=waterstream-playground --name ksql-shell --rm confluentinc/cp-ksql-cli http://ksqldb:8088
