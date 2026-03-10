#!/bin/sh
# Browser automation helper
# Usage:
#   ./browser.sh chromedriver           - Start chromedriver (finds Chrome automatically)
#   ./browser.sh start <url>            - Start session and navigate
#   ./browser.sh js <script>            - Execute JS and print result
#   ./browser.sh screenshot <output.png> - Take screenshot
#   ./browser.sh dark                   - Enable dark mode
#   ./browser.sh light                  - Enable light mode
#   ./browser.sh mobile                 - Set mobile viewport (375x812)
#   ./browser.sh desktop                - Set desktop viewport (1400x900)
#   ./browser.sh nav <url>              - Navigate to URL
#   ./browser.sh stop                   - End session
#   ./browser.sh kill                   - Kill chromedriver

PORT_FILE="/tmp/chromedriver_port"
SESSION_FILE="/tmp/chrome_session_id"

get_port() {
  if [ -f "$PORT_FILE" ]; then
    cat "$PORT_FILE"
  else
    echo "No chromedriver running. Run: ./browser.sh chromedriver" >&2
    exit 1
  fi
}

find_chrome() {
  for cmd in google-chrome-stable google-chrome chromium chromium-browser; do
    path=$(which "$cmd" 2>/dev/null)
    if [ -n "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  echo "No Chrome/Chromium found" >&2
  exit 1
}

case "$1" in
  chromedriver)
    # Kill any existing chromedriver
    if [ -f "$PORT_FILE" ]; then
      OLD_PORT=$(cat "$PORT_FILE")
      curl -s -X DELETE "http://localhost:$OLD_PORT/shutdown" 2>/dev/null || true
      rm -f "$PORT_FILE" "$SESSION_FILE"
      sleep 0.5
    fi

    # Start chromedriver and capture port
    LOG_FILE="/tmp/chromedriver.log"
    nohup chromedriver > "$LOG_FILE" 2>&1 &
    PID=$!

    # Wait for startup and extract port
    for i in 1 2 3 4 5; do
      sleep 0.5
      PORT=$(grep -o 'successfully on port [0-9]*' "$LOG_FILE" 2>/dev/null | grep -o '[0-9]*')
      if [ -n "$PORT" ]; then
        echo "$PORT" > "$PORT_FILE"
        echo "ChromeDriver started on port $PORT (pid $PID)"
        exit 0
      fi
    done

    echo "Failed to start ChromeDriver"
    cat "$LOG_FILE"
    exit 1
    ;;

  start)
    PORT=$(get_port)
    CHROME=$(find_chrome)
    URL="${2:-http://localhost:4000/}"

    SESSION=$(curl -s -X POST "http://localhost:$PORT/session" \
      -H "Content-Type: application/json" \
      -d "{\"capabilities\": {\"alwaysMatch\": {\"goog:chromeOptions\": {\"binary\": \"$CHROME\", \"args\": [\"--headless\", \"--window-size=1400,900\"]}}}}" \
      | jq -r '.value.sessionId')

    if [ -z "$SESSION" ] || [ "$SESSION" = "null" ]; then
      echo "Failed to create session"
      exit 1
    fi
    echo "$SESSION" > "$SESSION_FILE"

    curl -s -X POST "http://localhost:$PORT/session/$SESSION/url" \
      -H "Content-Type: application/json" \
      -d "{\"url\": \"$URL\"}" > /dev/null

    echo "Session started: $SESSION"
    echo "Navigated to: $URL"
    ;;

  js)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    SCRIPT="$2"
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/execute/sync" \
      -H "Content-Type: application/json" \
      -d "{\"script\": \"return $SCRIPT\", \"args\": []}" \
      | jq -r '.value'
    ;;

  screenshot)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    OUTPUT="${2:-/tmp/screenshot.png}"
    curl -s "http://localhost:$PORT/session/$SESSION/screenshot" \
      | jq -r '.value' | base64 -d > "$OUTPUT"
    echo "Screenshot saved to $OUTPUT"
    ;;

  dark)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/chromium/send_command" \
      -H "Content-Type: application/json" \
      -d '{"cmd": "Emulation.setEmulatedMedia", "params": {"features": [{"name": "prefers-color-scheme", "value": "dark"}]}}' > /dev/null
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/refresh" \
      -H "Content-Type: application/json" > /dev/null
    echo "Dark mode enabled"
    ;;

  light)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/chromium/send_command" \
      -H "Content-Type: application/json" \
      -d '{"cmd": "Emulation.setEmulatedMedia", "params": {"features": [{"name": "prefers-color-scheme", "value": "light"}]}}' > /dev/null
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/refresh" \
      -H "Content-Type: application/json" > /dev/null
    echo "Light mode enabled"
    ;;

  mobile)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/chromium/send_command" \
      -H "Content-Type: application/json" \
      -d '{"cmd": "Emulation.setDeviceMetricsOverride", "params": {"width": 375, "height": 812, "deviceScaleFactor": 1, "mobile": true}}' > /dev/null
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/refresh" \
      -H "Content-Type: application/json" > /dev/null
    echo "Mobile viewport set (375x812)"
    ;;

  desktop)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/chromium/send_command" \
      -H "Content-Type: application/json" \
      -d '{"cmd": "Emulation.clearDeviceMetricsOverride", "params": {}}' > /dev/null
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/refresh" \
      -H "Content-Type: application/json" > /dev/null
    echo "Desktop viewport restored (1400x900)"
    ;;

  nav|goto)
    PORT=$(get_port)
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No session. Run: ./browser.sh start <url>"
      exit 1
    fi
    URL="$2"
    curl -s -X POST "http://localhost:$PORT/session/$SESSION/url" \
      -H "Content-Type: application/json" \
      -d "{\"url\": \"$URL\"}" > /dev/null
    echo "Navigated to: $URL"
    ;;

  stop)
    PORT=$(get_port 2>/dev/null) || true
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null)
    if [ -z "$SESSION" ]; then
      echo "No active session"
      exit 0
    fi
    if [ -n "$PORT" ]; then
      curl -s -X DELETE "http://localhost:$PORT/session/$SESSION" > /dev/null
    fi
    rm -f "$SESSION_FILE"
    echo "Session ended"
    ;;

  kill)
    if [ -f "$PORT_FILE" ]; then
      PORT=$(cat "$PORT_FILE")
      curl -s -X DELETE "http://localhost:$PORT/shutdown" 2>/dev/null || true
      rm -f "$PORT_FILE" "$SESSION_FILE"
      echo "ChromeDriver stopped"
    else
      echo "No chromedriver running"
    fi
    ;;

  *)
    echo "Usage: ./browser.sh <command> [args]"
    echo "Commands: chromedriver, start, js, screenshot, dark, light, mobile, desktop, nav, stop, kill"
    ;;
esac
