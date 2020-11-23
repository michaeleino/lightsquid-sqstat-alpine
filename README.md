# lightsquid-sqstat-alpine
lightsquid with SQstat for squid analysis and monitoring on alpine

#### usage:
```
docker run -dit
            -p 8181:80
            --name lightsuid-sqstat  
            -e SQUIDHOST=${squid IP/HOST}
            -e SQUIDPORT=${squid port}
            -v /path/squid/access.log:/var/log/squid/access.log
            -v /path/lighttpd-cron:/etc/crontabs/lighttpd
            michaeleino/lightsquid-sqstat-alpine:1.0
```
