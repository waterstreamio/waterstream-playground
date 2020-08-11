#!/bin/bash

GRAFANA_HOST=grafana

until curl http://admin:admin@$GRAFANA_HOST:3000 2>&1; do
    echo "Grafana not ready yet"
    sleep 5
done

curl -XPOST -H "Content-Type: application/json" -d '{
  "name":"user1",
  "login":"user1",
  "password":"password1"
}' http://admin:admin@$GRAFANA_HOST:3000/api/admin/users

curl -XPOST -H "Content-Type: application/json" -d '{
  "name":"anonymous_org"
}' http://admin:admin@$GRAFANA_HOST:3000/api/orgs



