# chunhui2001/mongodb:mongo_8.0.0-rc4
FROM mongo:8.0.0-rc4
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"

### Install dev tools
RUN apt-get update -y && \
apt-get install -y vim build-essential lsb-release net-tools \
iputils-ping apt-utils wget ttf-wqy-microhei locales iproute2 && \
apt-get clean && apt-get autoclean


# 设定时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 开启中文支持
RUN locale-gen zh_CN.UTF-8 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN locale-gen zh_CN.UTF-8

ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN:zh
ENV LC_ALL zh_CN.UTF-8

WORKDIR /data/db

# docker build -f Dockerfile . -t 'chunhui2001/mongodb:mongo_8.0.0-rc4'
# docker run -dit --entrypoint="top" --name mongodb-8.0.0-rc4 chunhui2001/mongodb:mongo_8.0.0-rc4
# docker run -dit -p 27017:27017 --name mongodb-8.0.0-rc4 chunhui2001/mongodb:mongo_8.0.0-rc4

# Open ports
EXPOSE 27017 28017


