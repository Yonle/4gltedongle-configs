#!/usr/bin/env bash

NTFY_TOPIC="mysms123"
NTFY_URL="https://ntfy.sh/${NTFY_TOPIC}"

check() {
	mmcli -m any --messaging-list-sms --output-json \
	| jq -r '."modem.messaging.sms"[]?' \
	| while read -r sms_path; do
	    sms_json="$(mmcli -s "$sms_path" --output-json)"

	    number="$(jq -r '.sms.content.number // "Unknown"' <<< "$sms_json")"
	    text="$(jq -r '.sms.content.text // ""' <<< "$sms_json")"
	    timestamp="$(jq -r '.sms.properties.timestamp // ""' <<< "$sms_json")"

	    echo "INCOMMING: processing SMS from $number ..."

	    # Skip empty SMS
	    [[ -z "$text" ]] && continue

	    title="$number"

	    if curl \
	        --silent \
	        --show-error \
	        --fail \
	        -H "Title: $title" \
	        -H "Tags: incoming_envelope" \
	        -H "Priority: default" \
	        -d "$text

---
Timestamp: $timestamp" \
	        "$NTFY_URL" > /dev/null
	    then
	        mmcli -m any --messaging-delete-sms="${sms_path##*/}"
	    else
	        echo "Failed to deliver $sms_path, keeping message."
	    fi

	done

	echo "Checking back in 10sec..."
}

check

while sleep 10; do check; done
