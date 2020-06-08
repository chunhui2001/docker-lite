# chunhui2001/alpine_3.12.filebeat:8.4.0
# Version 0.0.1
FROM alpine:3.12.0

LABEL MAINTAINER="Keesh.zhang<chunhui2001@gmail.com>"
LABEL APP="grafana"
LABEL APP_REPOSITORY="https://github.com/grafana/grafana/releases"

#########################################
# apk add iproute2 # ss vs netstat      #
# ss -ptl                               #
# apk add drill # drill vs nslookup&dig #
# 中文支持                               #
# curl  mongodb                         #
# 时区支持                               #
# 查看系统版本 $ cat /etc/alpine-release  #
#########################################

ENV CURL_VERSION 7.50.1
ENV LANG=C.UTF-8

ENV GRAFANA_VERSION 7.3.7
ENV GLIBC_VERSION 2.27-r0
ENV GF_INSTALL_PLUGINS ""
ENV FILEBEAT_VERSION=8.4.0

ENV ALPINE_GLIBC_BASE_URL https://github.com/sgerrand/alpine-pkg-glibc/releases/download
ENV ALPINE_GLIBC_PACKAGE_VERSION $GLIBC_VERSION
ENV ALPINE_GLIBC_BASE_PACKAGE_FILENAME glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk
ENV ALPINE_GLIBC_BIN_PACKAGE_FILENAME glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk
ENV ALPINE_GLIBC_I18N_PACKAGE_FILENAME glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk

ENV ALPINE_GLIBC_BASE_PACKAGE_FILENAME_DL $ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME
ENV ALPINE_GLIBC_BIN_PACKAGE_FILENAME_DL $ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME
ENV ALPINE_GLIBC_I18N_PACKAGE_FILENAME_DL $ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' >> /etc/apk/repositories && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories && \
    apk update && apk upgrade && apk add bash build-base coreutils yaml-cpp=0.6.2-r2 && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add -U tzdata && apk add su-exec iproute2 && apk add drill busybox-extras && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME_DL" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME_DL" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME_DL" && \
    apk add --no-cache "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates && \
    apk add --update --no-cache --virtual curldeps g++ make perl && \
        wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
        tar xjvf curl-$CURL_VERSION.tar.bz2 && rm curl-$CURL_VERSION.tar.bz2 && cd curl-$CURL_VERSION && \
        ./configure --with-nghttp2=/usr --prefix=/usr --with-ssl --enable-ipv6 --enable-unix-sockets --without-libidn --disable-static --disable-ldap --with-pic && \
        make && make install && \
        cd / && rm -r curl-$CURL_VERSION && rm -r /var/cache/apk && rm -r /usr/share/man && \
        apk del curldeps && apk del glibc-i18n && rm "/root/.wget-hsts" && apk del .build-dependencies && \
        rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" 


WORKDIR /usr/local

# /filebeat/filebeat.yml
COPY ./config/filebeat.yml /

RUN curl https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -o /usr/local/filebeat.tar.gz && \
    tar xzvf filebeat.tar.gz && \
    rm filebeat.tar.gz && \
    mv filebeat-${FILEBEAT_VERSION}-linux-x86_64 filebeat

RUN ln -s /usr/local/filebeat/filebeat /usr/bin/filebeat

### 查看版本
# filebeat version

### 运行
# filebeat -e -c filebeat.yml

WORKDIR /usr/local/filebeat
VOLUME /usr/local/filebeat/data

CMD ["filebeat", "-e", "-c", "filebeat.yml"]

# docker build -f Dockerfile . -t 'chunhui2001/alpine_3.12.filebeat:8.4.0'
# docker run -dit --entrypoint="top" --name filebeat_8.4.0 chunhui2001/alpine_3.12.filebeat:8.4.0

