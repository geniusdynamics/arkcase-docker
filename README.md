# ARK CASE DOCKER IMAGE
This docker file in not complete its still under development

# BUILD DOCKER FILE
```shell
sudo docker build -t ark-case:latest .
```
# RUN POSTRES DATABASE
```shell

```

# RUN DOCKER COMMANDS
```shell
sudo docker run -d --name arkcase --network=ark-case-network -p 8080:8080 -p 443:443 -p 8983:8983 -p 61613:61613 -p 61616:61616 -p 9999:9999 ark-case:latest
```