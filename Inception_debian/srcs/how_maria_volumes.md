#### How to run a container with a "bind" to a folder:

```bash
docker run -d --name mariadb_container \
  --env-file .env \
  -v /home/mpeshko/data/mariadb:/var/lib/mysql \
  my_mariadb
```

Delete the container (docker rm -f) and check that the files in db_data remain!

The data should not disappear after
```bash
docker-compose down
```

But it should be deleted if you explicitly run

```bash
#the -v flag deletes the volumes
docker-compose down -v
```

