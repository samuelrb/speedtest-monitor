#!/bin/bash
set -e
set -x

export CRON_SCHEDULE=${CRON_SCHEDULE:-"0 * * * *"}

sed "s|\${CRON_SCHEDULE}|${CRON_SCHEDULE}|g" /usr/local/etc/templates/crontab.txt > /etc/cron.d/speedtest-cron
crontab /etc/cron.d/speedtest-cron
printenv | sed 's/^\([^=]*\)=\(.*\)$/\1="\2"/' > /etc/environment

cron -f
