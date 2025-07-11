FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y curl gnupg1 bc mailutils cron jq && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get install -y speedtest && \
    apt-get clean


COPY speedtest-check.sh /usr/local/bin/speedtest-check.sh
COPY crontab.txt /etc/cron.d/speedtest-cron

RUN chmod +x /usr/local/bin/speedtest-check.sh && \
    crontab /etc/cron.d/speedtest-cron

COPY init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"]
