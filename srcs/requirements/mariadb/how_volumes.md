#### How to run a container with a "bind" to a folder on your WSL:

```bash
docker run -d --name mariadb_container \
  --env-file .env \
  -v $(pwd)/db_data:/var/lib/mysql \
  my_mariadb
```

Here $(pwd)/db_data will create a db_data folder right in your current directory on WSL.

Delete the container (docker rm -f) and check that the files in db_data remain!