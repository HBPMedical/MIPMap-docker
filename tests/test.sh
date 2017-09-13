#!/usr/bin/env bash

set -e

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

cd "$(get_script_dir)"

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER_COMPOSE="docker-compose"
else
  DOCKER_COMPOSE="sudo docker-compose"
fi

$DOCKER_COMPOSE up -d test_db
$DOCKER_COMPOSE run wait_dbs
$DOCKER_COMPOSE run create_dbs

echo
echo "Test mapping a CSV file to another CSV file"
mkdir -p target
cp patient_exams_schema.csv target/patient_exams.csv
$DOCKER_COMPOSE run mipmap_to_files

echo "Check the results of mapping a CSV file to another CSV file"
diff -q ../target/patient_exams.csv target/patient_exams.csv

$DOCKER_COMPOSE run i2b2_datamart_setup
$DOCKER_COMPOSE run mipmap_to_i2b2_datamart
# TODO: test results

# Cleanup
echo
$DOCKER_COMPOSE stop
$DOCKER_COMPOSE rm -f > /dev/null 2> /dev/null
