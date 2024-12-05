#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# Define the plist directories and files
PLIST_DIR="$HOME/Library/LaunchAgents"
HTTP_PLIST_FILE="$PLIST_DIR/com.user.httpserver.plist"
UPDATE_PLIST_FILE="$PLIST_DIR/com.user.updatereport.plist"

# Ensure the LaunchAgents directory exists
mkdir -p "$PLIST_DIR"

# Get the current directory to use as the WorkingDirectory
WORKING_DIR=$(pwd)

# Create the HTTP server plist content
cat << EOF > "$HTTP_PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.httpserver</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/python3</string>
    <string>-m</string>
    <string>http.server</string>
    <string>8000</string>
    <string>--bind</string>
    <string>127.0.0.1</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>$WORKING_DIR</string>
  <key>StandardErrorPath</key>
  <string>/tmp/com.user.httpserver.err</string>
  <key>StandardOutPath</key>
  <string>/tmp/com.user.httpserver.out</string>
</dict>
</plist>
EOF

# Create the update report plist content
cat << EOF > "$UPDATE_PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.updatereport</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT_DIR/update_report.sh</string>
  </array>
  <key>StartInterval</key>
  <integer>60</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>$WORKING_DIR</string>
  <key>StandardErrorPath</key>
  <string>/tmp/com.user.updatereport.err</string>
  <key>StandardOutPath</key>
  <string>/tmp/com.user.updatereport.out</string>
</dict>
</plist>
EOF

# Load the HTTP server service
echo launchctl load -w "$HTTP_PLIST_FILE"
launchctl load -w "$HTTP_PLIST_FILE"
echo "HTTP server setup completed. The server will start automatically on boot."

# Load the update report service
echo launchctl load -w "$UPDATE_PLIST_FILE"
launchctl load -w "$UPDATE_PLIST_FILE"
echo "Update report setup completed. The script will run once every minute."

echo "Your OS will probably ask you about some permissions and in order for this to work you have to grant them."
echo "if everything works, you should be able to go to http://127.0.0.1:8000 and statistics over your computer usage will show."
