#!/bin/bash
set -e

export CRON_SCHEDULE=${CRON_SCHEDULE:-"0 * * * *"}

if [ -f /version.txt ]; then
  echo "🚀 Starting speedtest-monitor version: $(cat /version.txt)"
fi

sed "s|\${CRON_SCHEDULE}|${CRON_SCHEDULE}|g" /usr/local/etc/templates/crontab > /etc/cron.d/speedtest-cron
crontab /etc/cron.d/speedtest-cron
printenv | sed 's/^\([^=]*\)=\(.*\)$/\1="\2"/' > /etc/environment

cron -f
