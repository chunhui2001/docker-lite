# chunhui2001/alpine:3.12.pushgateway-1.2.0
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
#########################################

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
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
    apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates && \
    apk add --update --no-cache --virtual curldeps g++ make perl && \
        wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
        tar xjvf curl-$CURL_VERSION.tar.bz2 && rm curl-$CURL_VERSION.tar.bz2 && cd curl-$CURL_VERSION && \
        ./configure --with-nghttp2=/usr --prefix=/usr --with-ssl --enable-ipv6 --enable-unix-sockets --without-libidn --disable-static --disable-ldap --with-pic && \
        make && make install && \
        cd / && rm -r curl-$CURL_VERSION && rm -r /var/cache/apk && rm -r /usr/share/man && \
        apk del curldeps && apk del glibc-i18n && rm "/root/.wget-hsts" && apk del .build-dependencies && \
        rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
        curl -L https://github.com/prometheus/pushgateway/releases/download/v1.2.0/pushgateway-1.2.0.linux-amd64.tar.gz > /usr/local/pushgateway-1.2.0.linux-amd64.tar.gz && tar -zxvf /usr/local/pushgateway-1.2.0.linux-amd64.tar.gz -C /usr/local/ && \
        cp /usr/local/pushgateway-1.2.0.linux-amd64/pushgateway /usr/local/bin/


### pushgateway 不需要任何配置, 开箱即用
### 查看版本
# pushgateway --version

## 为了防止 pushgateway 重启或意外挂掉，导致数据丢失，我们可以通过 -persistence.file 和 -persistence.interval 参数将数据持久化下来。
WORKDIR /root
ENTRYPOINT ["pushgateway", "--web.listen-address=0.0.0.0:9091"]

EXPOSE 9091


# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.12.pushgateway-1.2.0'
# docker run -dit --entrypoint="top" -P --name alpine.pushgateway-1.2.0 chunhui2001/alpine:3.12.pushgateway-1.2.0
# docker run -dit -p 8080:8080 --name alpine.zhCN chunhui2001/alpine:3.12.pushgateway-1.2.0
# docker push chunhui2001/alpine:3.12.pushgateway-1.2.0
# docker pull chunhui2001/alpine:3.12.pushgateway-1.2.0


#### # echo "some_metric 3.14" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/some_job
#### 
#### cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/some_job/instance/some_instance
#### # TYPE some_metric counter
#### some_metric { label="val1" } 42
#### # TYPE another_metric gauge
#### # HELP another_metric Just an example.
#### another_metric 2398.283
#### EOF

### pushgateway 中的数据我们通常按照 job 和 instance 分组分类，
### 删除某个组下的某实例的所有数据：
# curl -X DELETE http://127.0.0.1:9091/metrics/job/some_job/instance/some_instance

### 删除某个组下的所有数据：
# curl -X DELETE http://127.0.0.1:9091/metrics/job/some_job

### Prometheus 每次从 PushGateway 拉取的数据，并不是拉取周期内用户推送上来的所有数据，而是最后一次 Push 到 PushGateway 上的数据，
### 所以推荐设置推送时间小于或等于 Prometheus 拉取的时间，这样保证每次拉取的数据是最新 Push 上来的。

### 查看推送到网关的指标
# curl http://localhost:9091/metrics



