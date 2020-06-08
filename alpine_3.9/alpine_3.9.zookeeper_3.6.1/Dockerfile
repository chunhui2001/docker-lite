# chunhui2001/alpine:3.9.zookeeper_3.6.1
FROM svlady/alpine-openjdk8-jre:8.191.12-r0
LABEL maintainer="slava.vladyshevsky[a]gmail.com"


#########################################
# apk add iproute2 # ss vs netstat      #
# ss -ptl                               #
# apk add drill # drill vs nslookup&dig #
# 中文支持                               #
# curl  zookeeper                       #
# 时区支持                               #
# 查看系统版本 $ cat /etc/alpine-release  #
#########################################


ENV CURL_VERSION 7.50.1
ENV LANG=C.UTF-8

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
        make && make install && \
        cd / && rm -r curl-$CURL_VERSION && rm -r /var/cache/apk && rm -r /usr/share/man && \
        apk del curldeps && apk del glibc-i18n && rm "/root/.wget-hsts" && apk del .build-dependencies && \
        rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" 

ARG PKG_VERSION=3.6.1
ARG PKG_NAME=zookeeper-${PKG_VERSION}
ARG PKG_NAME_2=apache-zookeeper-${PKG_VERSION}-bin
ARG ZK_HOME=/opt/zookeeper
ARG ZK_CLIENT_PORT=2181

ENV PATH=$PATH:$ZK_HOME/bin \
    ZOO_LOG4J_PROP=INFO,CONSOLE \
    ZK_USER=zookeeper \
    ZK_HOME=${ZK_HOME}

WORKDIR ${ZK_HOME}
RUN set -ex && \
    apk add --no-cache bash su-exec && \
    adduser -D -u 1000 -H -h ${ZK_HOME} ${ZK_USER} && \
    addgroup ${ZK_USER} root && \
    curl -L "https://downloads.apache.org/zookeeper/${PKG_NAME}/${PKG_NAME_2}.tar.gz" > /opt/"${PKG_NAME_2}.tar.gz" && \
    tar -zxf /opt/${PKG_NAME_2}.tar.gz -C ${ZK_HOME} && mv ${ZK_HOME}/${PKG_NAME_2}/* ${ZK_HOME} && rm -rf /opt/${PKG_NAME_2}.tar.gz && rm -rf ${ZK_HOME}/${PKG_NAME_2}

# adding entrypoint and startup scripts
COPY conf/bootstrap.sh $ZK_HOME/bin/
COPY conf/entrypoint.sh $ZK_HOME/bin/

RUN chmod +x $ZK_HOME/bin/*

EXPOSE ${ZK_CLIENT_PORT} 2888 3888
VOLUME ["${ZK_HOME}/data", "${ZK_HOME}/logs"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["bootstrap.sh", "zkServer.sh", "start-foreground"]

# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.9.zookeeper_3.6.1'
# docker run -dit --entrypoint="top" -P --name zookeeper_3.6.1 chunhui2001/alpine:3.9.zookeeper_3.6.1
# docker run -dit -p 8080:8080 --name alpine.kafka_2.4.0 chunhui2001/alpine:3.9.zookeeper_3.6.1
# docker push chunhui2001/alpine:3.9.zookeeper_3.6.1
# docker pull chunhui2001/alpine:3.9.zookeeper_3.6.1




