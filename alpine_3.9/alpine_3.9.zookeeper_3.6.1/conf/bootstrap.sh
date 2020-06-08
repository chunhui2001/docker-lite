#!/usr/bin/env bash

# enabling strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# setting defaults for configuration variables
ZK_SERVERS=${ZK_SERVERS:-""}
ZK_USER=${ZK_USER:-"zookeeper"}
ZK_LOG_LEVEL=${ZK_LOG_LEVEL:-"INFO"}
ZK_CONF_DIR=${ZK_CONF_DIR:-"$ZK_HOME/conf"}
ZK_DATA_DIR=${ZK_DATA_DIR:-"$ZK_HOME/data"}
ZK_LOGS_DIR=${ZK_LOGS_DIR:-"$ZK_HOME/logs"}
ZK_CONF_FILE="$ZK_CONF_DIR/zoo.cfg"
ZK_LOG4J_CONF="$ZK_CONF_DIR/log4j.properties"
ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-2181}
ZK_SERVER_PORT=${ZK_SERVER_PORT:-2888}
ZK_ELECTION_PORT=${ZK_ELECTION_PORT:-3888}
ZK_HEAP_SIZE=${ZK_HEAP_SIZE:-512M}
ZK_JVM_FLAGS=${ZK_JVM_FLAGS:-"-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true"}

### generating ZooKeeper log4j configuration
cat <<EOT>$ZK_LOG4J_CONF
zookeeper.root.logger=${ZOO_LOG4J_PROP}
zookeeper.console.threshold=${ZK_LOG_LEVEL}
log4j.rootLogger=\${zookeeper.root.logger}
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.Threshold=\${zookeeper.console.threshold}
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] %-5p [%C{2}] %m%n
EOT
# add specific loggers as defined by LOG4J_LOGGERS env variable
# e.g. ZK_LOG4J_LOGGERS="kafka.controller=WARN,kafka.foo.bar=DEBUG"
# will be translated to:
# log4j.logger.kafka.controller=WARN, CONSOLE
# log4j.logger.kafka.foo.bar=DEBUG, CONSOLE
for s in $(echo ${ZK_LOG4J_LOGGERS:-""} | tr ',' '\n'); do
  [ -z "${s##*=*}" ] && echo "log4j.logger.$s" >> $ZK_LOG4J_CONF
done
# JVM options
JVM_FLAGS="$ZK_JVM_FLAGS -Xmx${ZK_HEAP_SIZE} -Xms${ZK_HEAP_SIZE} -Dlog4j.configuration=file:${ZK_LOG4J_CONF}"
# JMX settings
# JMX_OPTS=${JMX_OPTS:-"-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"}
#
# if [ ${JMX_PORT:-""} ]; then
#     JMX_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT "
# fi
# add debug options if enabled
if [ ${ZK_JVM_DEBUG:-""} ]; then
  ZK_JVM_DEBUG_PORT=${ZK_JVM_DEBUG_PORT:-"5005"}
  # Use the defaults if JAVA_DEBUG_OPTS was not set
  JVM_DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=${ZK_JVM_DEBUG_SUSPEND_FLAG:-n},address=${ZK_JVM_DEBUG_PORT}"
  JVM_FLAGS="$JVM_FLAGS $JVM_DEBUG_OPTS"
fi
# add GC options if enabled
if [ ${ZK_JVM_GC_LOG:-} ]; then
  # The first segment of the version number, which is '1' for releases before Java 9
  # it then becomes '9', '10', ... Some examples of the first line of `java --version`:
  #   8 -> java version "1.8.0_152"
  #   9.0.4 -> java version "9.0.4"
  #   10 -> java version "10" 2018-03-20
  #   10.0.1 -> java version "10.0.1" 2018-04-17
  JAVA_MAJOR_VERSION=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
  if [[ "$JAVA_MAJOR_VERSION" -ge "9" ]] ; then
    JVM_GC_LOG_OPTS="-Xlog:gc*:file=$JVM_GC_LOG:time,tags:filecount=10,filesize=102400"
  else
    JVM_GC_LOG_OPTS="-Xloggc:${ZK_JVM_GC_LOG} -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M"
  fi
  JVM_FLAGS="$JVM_FLAGS $JVM_GC_LOG_OPTS"
fi
cat <<EOT >$ZK_CONF_DIR/java.env
JMXPORT=${ZK_JMX_PORT:-""}
SERVER_JVMFLAGS="$JVM_FLAGS"
CLIENT_JVMFLAGS="-Dzookeeper.root.logger=WARN,CONSOLE"
EOT
echo "===[ Environment ]============================================================="
env
echo "===[ Configuration: $ZK_CONF_FILE ]=============================="
cat $ZK_CONF_FILE
echo "===[ JVM Settings: $ZK_CONF_DIR/java.env ]=============================="
cat $ZK_CONF_DIR/java.env
echo "===[ ZooKeeper log: /dev/stdout ]=============================================="
[ $# -gt 0 ] && exec "$@"

