# chunhui2001/alpine:edge
# Version 0.0.1
FROM alpine:edge
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"

# For nghttp2-dev, we need this respository.
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >>/etc/apk/repositories 

ENV CURL_VERSION 7.50.1

RUN apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates
RUN apk add --update --no-cache --virtual curldeps g++ make perl && \
wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
tar xjvf curl-$CURL_VERSION.tar.bz2 && \
rm curl-$CURL_VERSION.tar.bz2 && \
cd curl-$CURL_VERSION && \
./configure \
    --with-nghttp2=/usr \
    --prefix=/usr \
    --with-ssl \
    --enable-ipv6 \
    --enable-unix-sockets \
    --without-libidn \
    --disable-static \
    --disable-ldap \
    --with-pic && \
make && \
make install && \
cd / && \
rm -r curl-$CURL_VERSION && \
rm -r /var/cache/apk && \
rm -r /usr/share/man && \
apk del curldeps
CMD ["curl"]


# docker build -f Dockerfile . -t 'chunhui2001/alpine:edge'
# docker run -dit --entrypoint="top" -P --name alpine.edge chunhui2001/alpine:edge
# docker run -dit -p 8080:8080 --name alpine.edge chunhui2001/alpine:edge
# docker push chunhui2001/alpine:edge
# docker pull chunhui2001/alpine:edge

# Open ports
# EXPOSE 80
