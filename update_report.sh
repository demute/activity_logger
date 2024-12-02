#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

/usr/bin/python3 update_activity.py >> activity.log
/usr/bin/python3 generate_report.py
