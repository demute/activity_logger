#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

python3 update_activity.py >> activity_log.jsonl

./update_quotas.pl > current_quotas.json.tmp
mv current_quotas.json.tmp current_quotas.json
