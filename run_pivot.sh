#!/bin/sh

echo "psql -h i2b2_db_harmonized -d i2b2 -U i2b2 -p 5432 -a -q -f /opt/source/pivot.sql"
psql -h i2b2_db_harmonized -d i2b2 -U i2b2 -p 5432 -a -q -f /opt/source/pivot.sql
