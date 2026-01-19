Automatically remove the container and its associated anonymous volumes when it exits
```bash
docker rm -f mariadb_container
```

Delete image:
```bash
docker rmi my_mariadb
```

Try this “nuclear” cleaning method before the next build:

```bash
docker stop $(docker ps -qa) 2>/dev/null
docker rm $(docker ps -qa) 2>/dev/null
docker rmi -f $(docker images -qa)
docker volume prune -f
```

This command only removes Named Volumes. It absolutely "does not see" Bind Mount, because for Docker your /home/mpeshko/data/mariadb folder is just part of your file system, not a Docker object.
```bash
docker volume rm $(docker volume ls -q)
```

or
```bash
docker system prune -a --volumes -f
```

How to remove Bind Mount?
To delete data stored via Bind Mount, you need to do it manually in your virtual machine's terminal:
```bash
sudo rm -rf /home/mpeshko/data/mariadb/*
# take ownership back
sudo chown -R mpeshko:mpeshko /home/mpeshko/data/mariadb

sudo rm -rf /home/mpeshko/data/wordpress/*
# take ownership back
sudo chown -R mpeshko:mpeshko /home/mpeshko/data/wordpress
```
