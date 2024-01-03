source /data/lingxi/.config
SERVICE=aftersales-service
UN_PORT=9500
VERSION=3.0.0
SERVICE_DIR=/data/lingxi/${SERVICE}
JAR_NAME=${SERVICE}-${VERSION}.jar
CONFIG=server
XMS=384m
XMX=512m

PID=$(ps -ef | grep $JAR_NAME | grep -v grep | awk '{print $2}')
if [[ -z $PID ]]; then
        echo "The server is not running -> "${JAR_NAME}
else
        echo "PID:"$PID
        kill -9 $PID
        echo "The server will restart -> "${JAR_NAME}
fi

cd ${SERVICE_DIR}

echo 'nohup run'
nohup java -jar -Duser.language=zh -Dserver.port=${UN_PORT}  -Xms${XMS} -Xmx${XMX} -XX:+UseParallelGC -XX:ParallelGCThreads=20  ${JAR_NAME} -jar   --spring.profiles.active=${CONFIG}   > /dev/null 2>&1 &

echo "PID:"$PID

echo "succeed"
