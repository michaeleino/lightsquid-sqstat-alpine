FROM alpine:3.12
# ARG RSVER=9.3

LABEL maintainer="Michael Fayez <michaeleino@hotmail.com>"
ENV SQUIDHOST=squid
ENV SQUIDPORT=3128
##Installing SQstat
RUN apk update && \
    apk add lighttpd php7 php7-common php7-iconv php7-json php7-gd php7-curl php7-xml php7-imap php7-cgi php7-pdo php7-pdo_mysql php7-soap php7-xmlrpc php7-posix php7-mcrypt php7-gettext php7-ldap php7-ctype php7-dom supervisor perl-cgi perl-gd fcgi patch && \
    sed -i 's/#   include "mod_fastcgi.conf"/   include "mod_fastcgi.conf"/g' /etc/lighttpd/lighttpd.conf && \
    cd /tmp && wget http://samm.kiev.ua/sqstat/sqstat-1.20.tar.gz && \
    tar -xvf sqstat-*.tar.gz && \
    rm -f sqstat-*.tar.gz && \
    mv sqstat-* /var/www/localhost/htdocs/sqstat && \
    cp /var/www/localhost/htdocs/sqstat/config.inc.php.defaults /var/www/localhost/htdocs/sqstat/config.inc.php && \
    sed -i 's/$squidhost\[0\]="127.0.0.1"/$squidhost\[0\]="getenv('SQUIDHOST')"/g' /var/www/localhost/htdocs/sqstat/config.inc.php && \
    sed -i 's/$squidport\[0\]=3128/$squidport\[0\]=getenv('SQUIDPORT')/g' /var/www/localhost/htdocs/sqstat/config.inc.php
    sed -i '$resolveip[0]=false/$resolveip[0]=true/g' /var/www/localhost/htdocs/sqstat/config.inc.php
## using the awesome patch provided by
### https://wiki.rtzra.ru/software/squid/squid-sqstat
ADD ./sqstat_squid_3.3.8.patch /var/www/localhost/htdocs/sqstat/sqstat_squid_3.3.8.patch
RUN cd /var/www/localhost/htdocs/sqstat/ && \
    patch sqstat.class.php sqstat_squid_3.3.8.patch && \
  #Install lightsuid
    cd /tmp && wget http://netix.dl.sourceforge.net/project/lightsquid/lightsquid/1.8/lightsquid-1.8.tgz && \
    tar -xvf lightsquid-*.tgz && rm -f lightsquid-*.tgz && \
    mv lightsquid-* /var/www/localhost/htdocs/lightsquid && \
    chmod +x /var/www/localhost/htdocs/lightsquid/*.cgi /var/www/localhost/htdocs/lightsquid/*.pl && \
    chown -R lighttpd: /var/www/localhost/htdocs/ && \
    sed -i 's:/html/:/localhost/htdocs/:g' /var/www/localhost/htdocs/lightsquid/lightsquid.cfg && \
    sed -i 's/#    "mod_alias"/    "mod_alias"/g' /etc/lighttpd/lighttpd.conf && \
    #enable mod_cgi and add directives for lightsuid path ;)
    echo 'server.modules += ("mod_cgi") \
    $HTTP["url"] =~ "^/lightsquid/" { \
    alias.url += ( "/lightsquid/" => "/var/www/localhost/htdocs/lightsquid/" ) \
    dir-listing.activate = "disable" \
    index-file.names  += ( "index.cgi" ) \
    cgi.assign = ( \
    ".pl"  => "/usr/bin/perl", \
    ".cgi"  => "/usr/bin/perl", \
    ) \
  }' >> /etc/lighttpd/lighttpd.conf && \
    mkdir /run/lighttpd/ && chown lighttpd: /run/lighttpd

ADD ./supervisor.d /etc/supervisor.d

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
