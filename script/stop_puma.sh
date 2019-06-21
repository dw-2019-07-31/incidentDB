#!/bin/sh

PROJECT_HOME="/home/rails/incidentDB"
PID_FILE="$PROJECT_HOME/tmp/pids/puma.pid"

if [ ! -e $PID_FILE ]; then
  /bin/echo "pid file does not exist."
  /bin/echo "puma already stopped."
  exit 0
fi

/bin/kill `/bin/cat $PID_FILE`

for i in `seq 1 30`
do
  PROCCESS_COUNT=`/bin/ps -ef | /bin/grep "unix:///$PROJECT_HOME/tmp/puma.sock" | /bin/grep -v grep | /bin/wc -l`
  if [ $PROCCESS_COUNT -eq 0 ] && [ ! -e $PID_FILE ]; then
    /bin/echo "Puma Stop Successfully. "
    exit 0
  fi
  /bin/sleep 1
done

exit 1
