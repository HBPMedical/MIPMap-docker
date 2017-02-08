# Docker container for MIPMap

Use the following command to build the MIPMap image:

   ```sh
    $ docker build -t hbpmip/mipmap \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` .
    ```
    
To use this image, you need a PostgreSQL database running.

A file named `postgresdb.properties` should be located at the root of the input data and contain the following:
```ini
  driver = org.postgresql.Driver
  uri = jdbc:postgresql://db:5432/
  username = mipmap
  password = mipmap
  mappingTask-DatabaseName = mipmap
```

username, password and mappingTask-DatabaseName need to be updated to match the PostgreSQL parameters.
The database is to be linked by default as ```db```. This can be changed in the URI above.

This container expects two folders to be mapped:

```yml
  - "${mipmap_source}:/opt/source:ro"
  - "${mipmap_target}:/opt/target:rw"
```
