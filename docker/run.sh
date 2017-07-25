#!/bin/bash

if [ -n "$MIPMAP_DB_PASSWORD" ]; then
  dockerize -template /etc/mipmap/mipmap_db.properties.tmpl:/opt/mipmap_db.properties
fi

java -jar /opt/MIPMapReduced.jar /opt/map.xml /opt/mipmap_db.properties $@
