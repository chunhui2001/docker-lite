# chunhui2001/alpine:3.13.python-3.8.7.kline
# Version 0.0.1
FROM chunhui2001/alpine:3.13.python-3.8.7
MAINTAINER Chunhui.Zhang "chunhui2001@gmail.com"

### Python draws an enhanced K-line chart: increasing the moving average and volume
# https://www.programmersought.com/article/9675405835/
# http://tushare.org/trading.html#id2

RUN python -m pip install --upgrade pip
RUN pip install matplotlib mplfinance

WORKDIR /root


# docker build -f Dockerfile . -t 'chunhui2001/alpine:3.13.python-3.8.7.kline'
# docker run -dit --entrypoint="top" --name python3 chunhui2001/alpine:3.13.python-3.8.7.kline

### 将容器打包成镜像
# docker commit [614122c0aabb] chunhui2001/alpine:3.13.python-3.8.7.kline

# Open ports
EXPOSE 8080


