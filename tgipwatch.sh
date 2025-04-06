#!/usr/bin/env bash

##
# tgipwatch.sh
#
# A script to monitor external IP changes and:
#   - send a Telegram message
#   - pin that message in a group
#
# Requirements:
#   - Bot is an admin in the group with "Pin Messages" permission
#   - jq is installed (for JSON parsing)
##

TELEGRAM_BOT_TOKEN="Get a new one with https://t.me/BotFather"
TELEGRAM_CHAT_ID="Usually is a negative number"
IP_FILE="/CHANGE/THIS/PATH"
LOG_FILE="/var/log/tgipwatch/history.log" #You might adapt this one too


# --- Functions ---
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Get the current external IP
get_current_ip() {
  # Use the service of your choice; 'ifconfig.me' is just an example
  curl -s https://ifconfig.me
}

# Send a Telegram message, return the message_id via stdout
send_message() {
  local text="$1"
  local response

  # Post the message to Telegram
  response="$(curl -s -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${text}")"

  # Extract the message_id from the JSON response
  echo "$response" | jq -r '.result.message_id'
}

# Pin a specific message_id in the chat
pin_message() {
  local msg_id="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/pinChatMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d message_id="${msg_id}" >/dev/null 2>&1
}

# Main logic
main() {
  # Read the previously stored IP (if file doesn’t exist, create empty)
  [ -f "$IP_FILE" ] || echo "" > "$IP_FILE"
  local stored_ip
  stored_ip="$(cat "$IP_FILE")"

  # Get the current external IP
  local current_ip
  current_ip="$(get_current_ip)"

  # If this is the first run or IP changed, send + pin a message
  if [ "$current_ip" != "$stored_ip" ]; then
    echo "$current_ip" > "$IP_FILE"  # Store the new IP

    local message="IP changed! New IP: ${current_ip}"

    log "Detected IP change: $stored_ip -> $current_ip"

    local new_msg_id
    new_msg_id="$(send_message "$message")"

    pin_message "$new_msg_id"

    log "Sent and pinned message ID: $new_msg_id"
  fi
}

# Execute main
main
