FROM alpine:3.12
LABEL maintainer="Michael Fayez <michaeleino@hotmail.com>"
#set default values for SQstat
ENV SQUIDHOST=squid
ENV SQUIDPORT=3128
##Installing SQstat
RUN apk update && \
    apk add lighttpd php7 php7-common php-session php7-iconv php7-json php7-gd php7-curl php7-xml php7-imap php7-cgi php7-pdo php7-pdo_mysql php7-soap php7-xmlrpc php7-posix php7-mcrypt php7-gettext php7-ldap php7-ctype php7-dom supervisor perl-cgi gd perl-gd fcgi && \
    #enable mod_fastcgi
    sed -i 's/#   include "mod_fastcgi.conf"/   include "mod_fastcgi.conf"/g' /etc/lighttpd/lighttpd.conf
ADD ./sqstat /var/www/localhost/htdocs/sqstat

#Install lightsuid
RUN cd /tmp && wget http://netix.dl.sourceforge.net/project/lightsquid/lightsquid/1.8/lightsquid-1.8.tgz && \
    tar -xvf lightsquid-*.tgz && rm -f lightsquid-*.tgz && \
    mv lightsquid-* /var/www/localhost/htdocs/lightsquid && \
    chmod +x /var/www/localhost/htdocs/lightsquid/*.cgi /var/www/localhost/htdocs/lightsquid/*.pl && \
    chown -R lighttpd: /var/www/localhost/htdocs/ && \
    sed -i 's:/html/:/localhost/htdocs/:g' /var/www/localhost/htdocs/lightsquid/lightsquid.cfg && \
    sed -i 's:/var/log/squid:/var/squid:g' /var/www/localhost/htdocs/lightsquid/lightsquid.cfg && \
    sed -i 's:$ip2name="simple":$ip2name="dns":g' /var/www/localhost/htdocs/lightsquid/lightsquid.cfg && \
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
    mkdir /run/lighttpd/ && chown lighttpd: /run/lighttpd && \
    echo "*/20 * * * * /var/www/localhost/htdocs/lightsquid/lightparser.pl today" >> /etc/crontabs/root

ADD ./supervisor.d /etc/supervisor.d

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
