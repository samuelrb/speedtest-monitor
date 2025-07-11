#!/bin/bash

MIN_DOWNLOAD=${MIN_DOWNLOAD:-200}
MIN_UPLOAD=${MIN_UPLOAD:-200}
SERVER_ID=${SERVER_ID:-}

DATE=$(date '+%Y-%m-%d %H:%M:%S')

CMD="speedtest --accept-license --accept-gdpr --format=json"
if [[ -n "${SERVER_ID}" ]]; then
  CMD="${CMD} --server-id=${SERVER_ID}"
fi

RESULT=$(${CMD})
DOWNLOAD_BPS=$(echo "${RESULT}" | jq '.download.bandwidth')  # en Bytes/s
UPLOAD_BPS=$(echo "${RESULT}" | jq '.upload.bandwidth')      # en Bytes/s

DOWNLOAD_MBPS=$(echo "${DOWNLOAD_BPS} * 8 / 1000000" | bc -l)
UPLOAD_MBPS=$(echo "${UPLOAD_BPS} * 8 / 1000000" | bc -l)

echo "${DATE} - Result: ${RESULT}"
echo "${DATE} - Download: ${DOWNLOAD_MBPS} Mbps, Upload: ${UPLOAD_MBPS} Mbps"

if (( $(echo "${DOWNLOAD_MBPS} < ${MIN_DOWNLOAD}" | bc -l) )) || \
   (( $(echo "${UPLOAD_MBPS} < ${MIN_UPLOAD}" | bc -l) )); then
  echo "${DATE} - ⚠️ Warning: low speed (Download: ${DOWNLOAD_MBPS}, Upload: ${UPLOAD_MBPS})
  threshold (Download: ${MIN_DOWNLOAD}, Upload: ${MIN_UPLOAD})"
fi
