#!/bin/sh

# Use for seed nodes
#PORT="2552"
# Use for other nodes
PORT="0"

LOG_Q="testapp-`uuidgen`"

HOST="$(hostname)"

SEED1="n0001:2552"
SEED2="n0002:2552"
SEED3="n0003:2552"

LOG_DIR="/tmp/akka-logs"

AKKA_HOME="$(cd "$(cd "$(dirname "$0")"; pwd -P)"/..; pwd)"
AKKA_CLASSPATH="$AKKA_HOME/config:$AKKA_HOME/lib/*"

MEM_OPTS="-Xms1538M -Xmx1538M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LOG_DIR -XX:+UseParallelGC -XX:+UseCompressedOops"
PROFILE_OPTS="-XX:+UnlockCommercialFeatures -XX:+FlightRecorder -XX:FlightRecorderOptions=defaultrecording=true"
PRINT_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
# Only one JMX (port) per machine
#JMX_OPTS="-Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
JMX_OPTS=""
HOST_OPTS="-Dakka.remote.netty.tcp.hostname=$HOST -Dakka.cluster.seed-nodes.1=akka.tcp://TestApp@$SEED1 -Dakka.cluster.seed-nodes.2=akka.tcp://TestApp@$SEED2 -Dakka.cluster.seed-nodes.3=akka.tcp://TestApp@$SEED3"
PORT_OPTS="-Dakka.remote.netty.tcp.port=$PORT"
LOG_OPTS="-Dtestapp.log-dir=$LOG_DIR -Dtestapp.log-qualifier=$LOG_Q"
DEBUG="-Dakka.loglevel=DEBUG -Dakka.log-dead-letters=1000 -Dakka.remote.log-received-messages=on -Dakka.remote.log-sent-messages=on"
APP_OPTS="-Dakka.cluster.roles.1=backend"
JAVA_OPTS="$MEM_OPTS $PROFILE_OPTS $PRINT_GC_OPTS $JMX_OPTS $HOST_OPTS $PORT_OPTS $LOG_OPTS $APP_OPTS"
JAVA_HOME="/opt/jdk1.7.0_40"

mkdir -p $LOG_DIR

nohup $JAVA_HOME/bin/java $JAVA_OPTS -cp "$AKKA_CLASSPATH" -Dakka.home="$AKKA_HOME" akka.kernel.Main testapp.Boot > $LOG_DIR/${HOST}_${LOG_Q}_out.txt 2>&1 &
