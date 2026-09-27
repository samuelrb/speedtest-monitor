FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y curl gnupg1 bc mailutils cron jq tar ca-certificates && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        curl -sL https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz | tar xvz -C /usr/local/bin speedtest; \
    elif [ "$ARCH" = "amd64" ]; then \
        curl -sL https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz | tar xvz -C /usr/local/bin speedtest; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    chmod +x /usr/local/bin/speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


COPY docker/scripts/speedtest-check.sh /usr/local/bin/speedtest-check.sh
COPY docker/scripts/crontab /usr/local/etc/templates/crontab

RUN chmod +x /usr/local/bin/speedtest-check.sh

COPY docker/scripts/init.sh /init.sh
COPY version.txt /version.txt
RUN chmod +x /init.sh

CMD ["/init.sh"]
