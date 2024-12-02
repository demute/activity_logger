#!/usr/bin/env python3
import Quartz
import time
from datetime import datetime
import subprocess
import re

def get_idle_time():
    return Quartz.CGEventSourceSecondsSinceLastEventType(Quartz.kCGEventSourceStateHIDSystemState, Quartz.kCGAnyInputEventType)

def toggle_mission_control():
    cmd = """osascript -e 'tell application "System Events" to key code 160'"""
    subprocess.call(cmd, shell=True)

def maximise_active_window():
    cmd = """osascript -e 'tell application "Finder" to get bounds of window of desktop' -e 'tell application "System Events" to tell process (name of first application process whose frontmost is true) to tell window 1 to set {position, size} to {{0, 0}, {item 3 of result, item 4 of result}}' > /dev/null"""
    subprocess.call(cmd, shell=True)

def get_name_of_active_window():
    cmd = """osascript -e 'tell application "System Events" to name of application processes whose frontmost is true'"""
    result = subprocess.check_output(cmd, shell=True, text=True).strip()
    return result

def get_url_of_active_google_chrome_tab():
    cmd = """osascript -e 'tell application "Google Chrome" to get URL of active tab of front window'"""
    result = subprocess.check_output(cmd, shell=True, text=True).strip()
    return result

def get_title_of_active_google_chrome_tab():
    cmd = """osascript -e 'tell application "Google Chrome" to get title of active tab of front window'"""
    result = subprocess.check_output(cmd, shell=True, text=True).strip()
    return result

def main():
    tsp = datetime.now().strftime("%Y-%m-%d %H:%M")
    activeApp = get_name_of_active_window()
    idleTime = int (get_idle_time())

    if activeApp == "Google Chrome":
        title = get_title_of_active_google_chrome_tab()
        url = get_url_of_active_google_chrome_tab()
        domain = url
        match = re.match(r'https?://([^/]+)', url)
        if match:
            domain = match.group(1)
        print(f"{tsp};{idleTime};{domain};{url};{title}")
    else:
        print(f"{tsp};{idleTime};{activeApp}")

if __name__ == '__main__':
    main()
