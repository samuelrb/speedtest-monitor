#!/bin/bash
set -e

set -a
[ -f /etc/environment ] && . /etc/environment
set +a

echo_log() {
  local level="${2:-info}"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$1\"}"
}

MIN_DOWNLOAD=${MIN_DOWNLOAD:-200}
MIN_UPLOAD=${MIN_UPLOAD:-200}
SERVER_ID=${SERVER_ID:-}

DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

CMD="speedtest --accept-license --accept-gdpr --format=json"
if [[ -n "${SERVER_ID}" ]]; then
  CMD="${CMD} --server-id=${SERVER_ID}"
fi

RESULT=$(${CMD})
DOWNLOAD_BPS=$(echo "${RESULT}" | jq '.download.bandwidth')  # en Bytes/s
UPLOAD_BPS=$(echo "${RESULT}" | jq '.upload.bandwidth')      # en Bytes/s
RESULT_URL=$(echo "${RESULT}" | jq -r '.result.url')

DOWNLOAD_MBPS=$(echo "scale=2; ${DOWNLOAD_BPS} * 8 / 1000000" | bc -l)
UPLOAD_MBPS=$(echo "scale=2; ${UPLOAD_BPS} * 8 / 1000000" | bc -l)

echo_log "Result: ${RESULT}"
echo_log "Download: ${DOWNLOAD_MBPS} Mbps, Upload: ${UPLOAD_MBPS} Mbps"

if (( $(echo "${DOWNLOAD_MBPS} < ${MIN_DOWNLOAD}" | bc -l) )) || \
   (( $(echo "${UPLOAD_MBPS} < ${MIN_UPLOAD}" | bc -l) )); then
  echo_log "⚠️ Warning: low speed (Download: ${DOWNLOAD_MBPS}, Upload: ${UPLOAD_MBPS})
  threshold (Download: ${MIN_DOWNLOAD}, Upload: ${MIN_UPLOAD})"
  if [[ -n "${TELEGRAM_BOT_TOKEN}" && -n "${TELEGRAM_CHAT_ID}" ]]; then
    ALERT_MSG=$(cat <<EOF
🚨 *Internet Speed Alert*

📅 \`${DATE}\`

📉 *Download*: ${DOWNLOAD_MBPS} Mbps _(min: ${MIN_DOWNLOAD})_
📤 *Upload*: ${UPLOAD_MBPS} Mbps _(min: ${MIN_UPLOAD})_

🔗 [View full result](${RESULT_URL})
EOF
)
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d chat_id="${TELEGRAM_CHAT_ID}" \
      -d text="${ALERT_MSG}" \
      -d parse_mode="Markdown"
  fi
fi
