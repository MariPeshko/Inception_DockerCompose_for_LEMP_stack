## how to use docker-compose.yml

Use this command to start the application:
```bash
docker compose up -d --build
```

Stop and start
```bash
docker compose stop
docker compose start
```

Use this command to remove everything:
```bash
docker compose down
```

 If you do want to remove the volumes, add the --volumes flag
 ```bash
 docker compose down -v
 ```

 If you want to monitor the output of your running containers and debug issues, you can view the logs with:
 ```bash
 docker compose logs
 ```

 To list all the services along with their current status:
 ```bash
docker compose ps
 ```