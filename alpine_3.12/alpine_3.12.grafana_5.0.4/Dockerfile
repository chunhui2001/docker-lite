# chunhui2001/alpine:3.12.grafana_5.0.4
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

ENV GRAFANA_VERSION 5.0.4
ENV GLIBC_VERSION 2.27-r0
ENV GF_INSTALL_PLUGINS ""

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

WORKDIR /root

# Downloading Grafana Binaries    
ADD https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${GRAFANA_VERSION}.linux-x64.tar.gz /root
RUN addgroup grafana && adduser -s /bin/false -G grafana -S -D grafana

RUN tar -C . -xzf grafana-$GRAFANA_VERSION.linux-x64.tar.gz && \
        mv grafana-${GRAFANA_VERSION} /opt/grafana && \
        mkdir -p /var/lib/grafana/dashboards /var/lib/grafana/data /var/lib/grafana/logs /var/lib/grafana/plugins && \
        ln -s /var/lib/grafana/plugins /opt/grafana/plugins && \
        mv /opt/grafana/bin/* /usr/bin/ && \
        grafana-cli plugins update-all && \
        rm -f grafana-$GRAFANA_VERSION.linux-x64.tar.gz

# config file
# /opt/grafana/conf/defaults.ini

WORKDIR /root/grafana
COPY ./entrypont.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypont.sh
RUN chown -R grafana:grafana /opt/grafana
RUN chown -R grafana:grafana /var/lib/grafana
VOLUME  [ "/opt/grafana" ]
EXPOSE 3000
ENTRYPOINT ["entrypont.sh"]

# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.12.grafana_5.0.4'
# docker run -dit --entrypoint="top" --name grafana_5.0.4 chunhui2001/alpine:3.12.grafana_5.0.4
# docker run -dit -p 3000:3000 --name grafana_5.0.4 chunhui2001/alpine:3.12.grafana_5.0.4

