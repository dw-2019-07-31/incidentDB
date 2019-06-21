#!/bin/sh

. /home/rails/.bash_profile

PROJECT_HOME="/home/rails/incidentDB"
PID_FILE="$PROJECT_HOME/tmp/pids/puma.pid"

cd $PROJECT_HOME

if [ -e $PID_FILE ]; then
  /bin/echo "pid file exist."
  /bin/echo "puma already started."
  exit 0
fi

# カレントディレクトリに依存するコマンドであるため、
# 絶対パスでのコマンド指定をしない。
rails server

for i in `seq 1 30`
do
  PROCCESS_STRING="unix:///$PROJECT_HOME/tmp/puma.sock"
  PROCCESS_COUNT=`/bin/ps -ef | /bin/grep $PROCCESS_STRING | /bin/grep -v grep | /bin/wc -l`
  if [ $PROCCESS_COUNT -ge 1 ] && [ -e $PID_FILE ]; then
    PID=`/bin/cat $PID_FILE`
    /bin/echo "Puma Start Successfully. $PID"
    exit 0
  fi
  /bin/sleep 1
done

exit 1
