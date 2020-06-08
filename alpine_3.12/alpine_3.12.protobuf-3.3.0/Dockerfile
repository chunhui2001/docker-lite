# chunhui2001/alpine:3.12.protobuf-3.3.0
FROM alpine:3.12.0
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"


#########################################
# apk add iproute2 # ss vs netstat      #
# ss -ptl                               #
# apk add drill # drill vs nslookup&dig #
# 中文支持                               #
# curl golang protobuf                  #
# 时区支持                               #
# 查看系统版本 $ cat /etc/alpine-release  #
#########################################


ENV LANG=C.UTF-8
ENV GO_VERSION 1.10.1
ENV PROTOBUF_VERSION 3.3.0
ENV PROTOBUF_URL https://github.com/google/protobuf/releases/download/v$PROTOBUF_VERSION/protobuf-cpp-$PROTOBUF_VERSION.tar.gz

ENV PATH $PATH:/usr/local/protobuf/bin:/usr/local/go/bin

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  apk update && apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add -U tzdata && apk add iproute2 && apk add drill busybox-extras && \
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
    apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates curl curl-dev bash su-exec g++ gcc libgcc git && \
    apk add --update --no-cache --virtual curldeps alpine-sdk make perl build-base autoconf automake libtool libbsd-dev libbsd gnupg && \
   \
   wget https://github.com/leannenorthrop/alpine-pkg-glibc/releases/download/glibc-2.22-r1-armhf-beta/glibc-2.22-r1.apk && \
   wget https://github.com/leannenorthrop/alpine-pkg-glibc/releases/download/glibc-2.22-r1-armhf-beta/glibc-bin-2.22-r1.apk && \
   apk add --allow-untrusted glibc-2.22-r1.apk && \
   apk add --allow-untrusted glibc-bin-2.22-r1.apk && \
   cp /usr/glibc-compat/lib/ld-linux-armhf.so.3 /lib && rm -rf glibc-*.apk && \
   \
   curl -L -o /tmp/go$GO_VERSION.linux-armv6l.tar.gz https://storage.googleapis.com/golang/go$GO_VERSION.linux-armv6l.tar.gz && \
   tar -C /usr/local -xvzf /tmp/go$GO_VERSION.linux-armv6l.tar.gz && rm -rf /tmp/go$GO_VERSION.linux-armv6l.tar.gz && \
   \
   curl -L -o /tmp/protobuf.tar.gz $PROTOBUF_URL && tar xvzf /tmp/protobuf.tar.gz -C /tmp && \
   \
   mkdir /usr/local/protobuf && \
   cd /tmp/protobuf-$PROTOBUF_VERSION && ./autogen.sh && ./configure --prefix=/usr/local/protobuf && make -j 3 && make install && \
   \
   cd / && rm -r /var/cache/apk && rm -r /usr/share/man && \
   apk del curldeps && apk del glibc-i18n && rm "/root/.wget-hsts" && apk del .build-dependencies && \
   rm -rf /tmp/protobuf* && rm -rf /tmp/go* && rm -rf /root/.cache && rm -rf /root/.ash_history

RUN go get github.com/golang/protobuf/protoc-gen-go && cp /root/go/bin/protoc-gen-go /usr/local/protobuf/bin/ && \
   cp /usr/lib/libstdc++* /usr/local/protobuf/lib/ && cp /usr/lib/libgcc_s* /usr/local/protobuf/lib/ && rm -rf /root/go


WORKDIR /root

### 查看版本
# protoc --version
# go version

# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.12.protobuf-3.3.0'
# docker run -dit --entrypoint="top" -P --name protobuf-3.3.0 chunhui2001/alpine:3.12.protobuf-3.3.0
# docker run -dit -p 8080:8080 --name protobuf-3.3.0 chunhui2001/alpine:3.12.protobuf-3.3.0
# docker push chunhui2001/alpine:3.12.protobuf-3.3.0
# docker pull chunhui2001/alpine:3.12.protobuf-3.3.0

