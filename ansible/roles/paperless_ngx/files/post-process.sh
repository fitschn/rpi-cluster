#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -n "${DOCUMENT_ARCHIVE_PATH}" ]; then
    echo "Sende Dokument an PrivateGPT ..."

    curl -s -X POST "https://pgpt.ohr-mit-n.net/v1/ingest/file" \
        -H "Content-Type: multipart/form-data" -F file=@${DOCUMENT_ARCHIVE_PATH}

    echo -e "\nDokument ${DOCUMENT_FILE_NAME} wurde an PrivateGPT geschickt."

else
    source ${SCRIPT_DIR}/pushover.credentials
    echo "Dokument konnte nicht verarbeitet werden. Notification wird verschickt ..."

    curl -s --form-string "token=${APP_TOKEN}" --form-string "user=${USER_KEY}" \
        --form-string "message=[Paperless-NGX] Dokument ${DOCUMENT_FILE_NAME} konnte nicht verarbeitet werden." \
        "https://api.pushover.net/1/messages.json"

    echo -e "\nBenachrichtigung wurde verschickt."
fi
