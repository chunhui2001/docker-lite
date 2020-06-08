# chunhui2001/alpine:3.19.redis-7.2.3
# Version 0.0.1
FROM redis:7.2.3-alpine3.19
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"


#########################################
# apk add iproute2 # ss vs netstat      #
# ss -ptl                               #
# apk add drill # drill vs nslookup&dig #
# 中文支持 								#
# curl  redis 							#
# 时区支持 								#
# 查看系统版本 $ cat /etc/alpine-release 	#
#########################################

ENV CURL_VERSION 7.50.1
ENV LANG=C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
apk add -U tzdata && apk add iproute2 && apk add drill busybox-extras && \
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
echo "export LS_OPTIONS='--color=auto'" > "/root/.profile" && \
echo "alias ls='ls $LS_OPTIONS'" >> "/root/.profile" && \
echo "alias ll='ls $LS_OPTIONS -alh'" >> "/root/.profile" && \
echo "alias l='ls $LS_OPTIONS -lA'" >> "/root/.profile" && source /root/.profile && \
echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates && \
apk add --update --no-cache --virtual curldeps g++ make perl ruby && gem install redis --version 3.3.3 && \
wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
tar xjvf curl-$CURL_VERSION.tar.bz2 && rm curl-$CURL_VERSION.tar.bz2 && cd curl-$CURL_VERSION && \
./configure --with-nghttp2=/usr --prefix=/usr --with-ssl --enable-ipv6 --enable-unix-sockets \
--without-libidn --disable-static --disable-ldap --with-pic && \
make && make install && \
cd /root && rm -rf curl-$CURL_VERSION && rm -r /var/cache/apk && rm -r /usr/share/man && \
apk del curldeps && rm "/root/.wget-hsts" && apk del .build-dependencies && \
rm -rf curl-$CURL_VERSION && \
apk add --update --no-cache --virtual curldeps g++ make perl ruby && source ~/.profile

### adduser
RUN deluser redis && addgroup redis && adduser --disabled-password --gecos "" --home "$(pwd)" --ingroup redis --no-create-home --uid 12345 redis

### RUN mkdir /data && chown redis:redis /data

VOLUME ["/data"]
COPY conf/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# RUN apk add shadow && && echo "redis ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /root

## entrypoint.sh redis-server /etc/redis.conf
ENTRYPOINT ["entrypoint.sh"]
CMD ["redis-server", "/etc/redis.conf"]

# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.19.redis-7.2.3'
# docker run -dit --entrypoint="top" --name redis7.2.3 chunhui2001/alpine:3.19.redis-7.2.3
# docker run -dit -p 6379:6379 --name redis7.2.3 chunhui2001/alpine:3.19.redis-7.2.3

# Open ports
EXPOSE 6379


