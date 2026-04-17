#!/bin/bash

if [ "$(whoami)" != "root" ];
then
    echo must be run with sudo;
    exit 1
fi

# enable pf after reboot by installing this launchd script
TIMELIMIT_PLIST_FILE="/Library/LaunchDaemons/com.timelimit.pf.plist"


cat << EOF > "$TIMELIMIT_PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

  <key>Label</key>
  <string>com.timelimit.pf</string>

  <key>ProgramArguments</key>
  <array>
    <string>/sbin/pfctl</string>
    <string>-e</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

</dict>
</plist>
EOF

chown root:wheel "$TIMELIMIT_PLIST_FILE"
chmod 644        "$TIMELIMIT_PLIST_FILE"
launchctl load   "$TIMELIMIT_PLIST_FILE"


# add line to pf.conf if it's not there already
grep -q '^anchor "timelimit"$' /etc/pf.conf || echo 'anchor "timelimit"' >> /etc/pf.conf

cat << EOF > "/etc/pf.anchors/timelimit"
table <blocked> persist { youtube.com, www.youtube.com, youtu.be, discord.com, discord.gg }

block drop out quick proto tcp to <blocked> port { 80 443 }
block drop out quick proto udp to <blocked> port 443
EOF

pfctl -vnf /etc/pf.conf
pfctl -f /etc/pf.conf
pfctl -e
