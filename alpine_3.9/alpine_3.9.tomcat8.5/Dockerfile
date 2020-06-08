# chunhui2001/alpine:3.9.tomcat8.5
# Version 0.0.1
FROM chunhui2001/alpine:3.9.openjdk8
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"

ENV CURL_VERSION 7.50.1
ENV LANG=C.UTF-8

### $JAVA_ALPINE_VERSION
### ${JAVA_VERSION%%[-~bu]*}
ENV openjdk8 8.212.04-r0
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# let "Tomcat Native" live somewhere isolated
ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

# see https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/KEYS
# see also "update.sh" (https://github.com/docker-library/tomcat/blob/master/update.sh)
ENV GPG_KEYS 05AB33110949707C93A279E3D3EFE6B686867BA6 07E48665A34DCAFAE522E5E6266191C37C037D42 47309207D818FFD8DCD3F83F1931D684307A10A5 541FBE7D8F78B25E055DDEE13C370389288584E7 61B832AC2F1C5A90F0F9B00A1C506407564C17A3 713DA88BE50911535FE716F5208B0AB1D63011C7 79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED 9BA44C2621385CB966EBA586F72C284D731FABEE A27677289986DB50844682F8ACB77FC2E86E29AC A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.56
ENV TOMCAT_SHA512 7a02a8e0b12eea2e0bf1175d754bd19dc445e7182c2db033ba6ca1330161cc74207c9b9b7f0fce510417ece28f26cc36816b34eb394b0d27350631e64204aed3

ENV TOMCAT_TGZ_URLS \
    # https://issues.apache.org/jira/browse/INFRA-8753?focusedCommentId=14735394#comment-14735394
    https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    # if the version is outdated, we might have to pull from the dist/archive :/
    https://www-us.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

ENV TOMCAT_ASC_URLS \
    https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.asc \
    # not all the mirrors actually carry the .asc files :'(
    https://www-us.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.asc \
    https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.asc \
    https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.asc

RUN set -eux; \
    \
    apk add --no-cache --virtual .fetch-deps \
        gnupg \
        \
        ca-certificates \
        openssl \
    ; \
    \
    export GNUPGHOME="$(mktemp -d)"; \
    for key in $GPG_KEYS; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done; \
    \
    success=; \
    for url in $TOMCAT_TGZ_URLS; do \
        if wget -O tomcat.tar.gz "$url"; then \
            success=1; \
            break; \
        fi; \
    done; \
    [ -n "$success" ]; \
    \
    echo "$TOMCAT_SHA512 *tomcat.tar.gz" | sha512sum -c -; \
    \
    success=; \
    for url in $TOMCAT_ASC_URLS; do \
        if wget -O tomcat.tar.gz.asc "$url"; then \
            success=1; \
            break; \
        fi; \
    done; \
    [ -n "$success" ]; \
    \
    gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz; \
    tar -xvf tomcat.tar.gz --strip-components=1; \
    rm bin/*.bat; \
    rm tomcat.tar.gz*; \
    rm -rf "$GNUPGHOME"; \ 
    mkdir -p /tmp/nativeBuildDir && \
    tar -xvf $CATALINA_HOME/bin/tomcat-native.tar.gz -C /tmp/nativeBuildDir --strip-components=1; \
    \
    apk add --no-cache --virtual .native-build-deps build-base \
        apr-dev coreutils dpkg-dev dpkg gcc libc-dev make openssl-dev && \
    \
    cd /tmp/nativeBuildDir/native  && \
    ./configure --build=x86_64-linux-musl --libdir="$TOMCAT_NATIVE_LIBDIR" \
                --prefix="$CATALINA_HOME" --with-apr="$(which apr-1-config)" \
                --with-java-home="$(docker-java-home)" --with-ssl=yes && \
    make -j "$(nproc)" && make install && rm -rf /tmp/nativeBuildDir && \
    \
    rm -rf $CATALINA_HOME/bin/tomcat-native.tar.gz; \
    runDeps="$( scanelf --needed --nobanner --format '%n#p' --recursive "$TOMCAT_NATIVE_LIBDIR" | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' )"; \
    apk add --virtual .tomcat-native-rundeps $runDeps; \
    apk del .fetch-deps .native-build-deps; \
    apk add --no-cache bash; \
    find $CATALINA_HOME/bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +

# verify Tomcat Native is working properly
RUN set -e \
    && nativeLines="$(catalina.sh configtest 2>&1)" \
    && nativeLines="$(echo "$nativeLines" | grep 'Apache Tomcat Native')" \
    && nativeLines="$(echo "$nativeLines" | sort -u)" \
    && echo >&2 "$nativeLines";

WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD ["catalina.sh", "run"]

# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.9.tomcat8.5'
# docker run -dit --entrypoint="top" -P --name alpine.tomcat8.5 chunhui2001/alpine:3.9.tomcat8.5
# docker run -dit -p 8181:8080 --name alpine.tomcat8.5 chunhui2001/alpine:3.9.tomcat8.5
# docker push chunhui2001/alpine:3.9.tomcat8.5
# docker pull chunhui2001/alpine:3.9.tomcat8.5


