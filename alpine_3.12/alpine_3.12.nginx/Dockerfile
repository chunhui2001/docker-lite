# chunhui2001/alpine:3.12.nginx
# Version 0.0.1
FROM alpine:3.12.0
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"

ENV CURL_VERSION 7.50.1
ENV LANG=C.UTF-8

#########################################
# apk add iproute2 # ss vs netstat      #
# ss -ptl                               #
# apk add drill # drill vs nslookup&dig #
# 中文支持                                #
# curl                                  #
# 时区支持                                #
# 查看系统版本 $ cat /etc/alpine-release   #
# nginx                                 #
# nginx -V                              #
# nginx -t                              #
# nginx -v                              #
# nginx -g "daemon off;"                #
#########################################

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add -U tzdata && apk add iproute2 && apk add drill && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "export LS_OPTIONS='--color=auto'" > "/root/.profile" && \
    echo "alias ls='ls $LS_OPTIONS'" >> "/root/.profile" && \
    echo "alias ll='ls $LS_OPTIONS -alh'" >> "/root/.profile" && \
    echo "alias l='ls $LS_OPTIONS -lA'" >> "/root/.profile" && source /root/.profile && \
    echo "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates && \
    apk add --update --no-cache --virtual curldeps g++ make perl && \
        wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
        tar xjvf curl-$CURL_VERSION.tar.bz2 && rm curl-$CURL_VERSION.tar.bz2 && cd curl-$CURL_VERSION && \
        ./configure --with-nghttp2=/usr --prefix=/usr --with-ssl --enable-ipv6 --enable-unix-sockets --without-libidn --disable-static --disable-ldap --with-pic && \
        make && make install && mkdir /run/nginx && \
    apk update && \
    apk add nginx && \
    adduser -D -g 'www' www && \
    mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig && \
    echo "user                            www;" > /etc/nginx/nginx.conf && \
    echo "worker_processes                auto; # it will be determinate automatically by the number of core" >> /etc/nginx/nginx.conf && \
    echo "error_log                       /var/log/nginx/error.log warn;" >> /etc/nginx/nginx.conf && \
    echo "#pid                             /var/run/nginx/nginx.pid; # it permit you to use /etc/init.d/nginx reload|restart|stop|start" >> /etc/nginx/nginx.conf && \
    echo "events {" >> /etc/nginx/nginx.conf && \
    echo "    worker_connections          1024;" >> /etc/nginx/nginx.conf && \
    echo "}" >> /etc/nginx/nginx.conf && \
    echo "http {" >> /etc/nginx/nginx.conf && \
    echo "    include                     /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf && \
    echo "    default_type                application/octet-stream;" >> /etc/nginx/nginx.conf && \
    echo "    sendfile                    on;" >> /etc/nginx/nginx.conf && \
    echo "    access_log                  /var/log/nginx/access.log;" >> /etc/nginx/nginx.conf && \
    echo "    keepalive_timeout           3000;" >> /etc/nginx/nginx.conf && \
    echo "    server {" >> /etc/nginx/nginx.conf && \
    echo "        listen                  80;" >> /etc/nginx/nginx.conf && \
    echo "        root                    /www;" >> /etc/nginx/nginx.conf && \
    echo "        index                   index.html index.htm;" >> /etc/nginx/nginx.conf && \
    echo "        server_name             localhost;" >> /etc/nginx/nginx.conf && \
    echo "        client_max_body_size    32m;" >> /etc/nginx/nginx.conf && \
    echo "        error_page              500 502 503 504  /50x.html;" >> /etc/nginx/nginx.conf && \
    echo "        location = /50x.html {" >> /etc/nginx/nginx.conf && \
    echo "              root              /var/lib/nginx/html;" >> /etc/nginx/nginx.conf && \
    echo "        }" >> /etc/nginx/nginx.conf && \
    echo "    }" >> /etc/nginx/nginx.conf && \
    echo "}" >> /etc/nginx/nginx.conf && \
    echo '<!DOCTYPE html>' > /www/index.html && \
    echo '<html lang="en">' >> /www/index.html && \
    echo '<head>' >> /www/index.html && \
    echo '    <meta charset="utf-8" />' >> /www/index.html && \
    echo '    <title>HTML5</title> >>' /www/index.html && \
    echo '</head>' >> /www/index.html && \
    echo '<body>' >> /www/index.html && \
    echo '    Server is online' >> /www/index.html && \
    echo '</body>' >> /www/index.html && \
    echo '</html>' >> /www/index.html && \
    cd / && rm -r curl-$CURL_VERSION && rm -r /var/cache/apk && rm -r /usr/share/man && \
        apk del curldeps && apk del glibc-i18n && rm "/root/.wget-hsts" && apk del .build-dependencies && \
        rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" 

WORKDIR /root
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80

# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.12.nginx'
# docker run -dit --entrypoint="top" -P --name alpine.nginx chunhui2001/alpine:3.12.nginx
# docker run -dit -p 18181:80 --name alpine.nginx chunhui2001/alpine:3.12.nginx
# docker push chunhui2001/alpine:3.12.nginx
# docker pull chunhui2001/alpine:3.12.nginx


