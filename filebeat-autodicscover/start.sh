#!/bin/bash

set -x

sed -e "s/##HOSTURL##/${HOSTURL:-localhost:9200}/; s/##ENVIRONMENT##/${ENVIRONMENT:-Rancher}/; s/##PROTOCOL##/${PROTOCOL:-http}/" /var/filebeat.yml > /usr/share/filebeat/filebeat.yml


/usr/local/bin/docker-entrypoint $*
