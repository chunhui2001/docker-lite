# chunhui2001/alpine:3.9.oraclejdk17
# Version 0.0.1
FROM alpine:3.9
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"

ENV CURL_VERSION 7.50.1
ENV LANG=C.UTF-8
ENV LANG C.UTF-8
ENV JAVA_HOME /usr/local/java

#########################################
# apk add iproute2 # ss vs netstat      #
# ss -ptl                               #
# apk add drill # drill vs nslookup&dig #
# 中文支持                                #
# curl oracle jdk 9                     #
# 时区支持                                #
# 查看系统版本 $ cat /etc/alpine-release   #
#########################################

WORKDIR /tmp

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
    apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates git libc6-compat curl bash && \
    apk add --update --no-cache --virtual curldeps g++ make perl && \
        wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
        tar xjvf curl-$CURL_VERSION.tar.bz2 && rm curl-$CURL_VERSION.tar.bz2 && cd curl-$CURL_VERSION && \
        ./configure --with-nghttp2=/usr --prefix=/usr --with-ssl --enable-ipv6 --enable-unix-sockets --without-libidn --disable-static --disable-ldap --with-pic && \
        make && make install  && \
        \
        cd / && rm -r /tmp/curl-* && rm -r /var/cache/apk && rm -r /usr/share/man && \
        apk del curldeps && apk del glibc-i18n && rm "/root/.wget-hsts" && apk del .build-dependencies && \
        rm  -r /tmp/glibc*

COPY asdf /root/asdf
#RUN source $HOME/asdf/asdf.sh &&\
#    asdf plugin-add java https://github.com/halcyon/asdf-java.git &&\
#    asdf install java adoptopenjdk-17.0.0+35 &&\

# $ ls -lah /root/.asdf/installs/java/adoptopenjdk-17.0.0+35/bin/java

CMD ["sh"]


# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.9.oraclejdk17'
# docker run -dit --entrypoint="top" -P --name alpine.oraclejdk17 chunhui2001/alpine:3.9.oraclejdk17
# docker run -dit -p 8080:8080 --name alpine.oraclejdk17 chunhui2001/alpine:3.9.oraclejdk17
# docker push chunhui2001/alpine:3.9.oraclejdk17
# docker pull chunhui2001/alpine:3.9.oraclejdk17

