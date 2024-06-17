# BUILD DOCKER FILE
```shell
sudo docker build -t ark-case:latest .
```

# RUN DOCKER COMMANDS
```shell
sudo docker run -d --name arkcase --network=ark-case-network -p 8080:8080 -p 443:443 -p 8983:8983 -p 61613:61613 -p 61616:61616 -p 9999:9999 ark-case:latest
```