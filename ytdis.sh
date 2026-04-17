#!/bin/bash
cd $(dirname ${BASH_SOURCE[0]})

# counts the number of minutes a user has been using youtube or discord, excluding tutorials and piano lessons

tac activity_log.jsonl | head -n 1440 | awk -F'[:,]' -v now=$(date +%s) '{ ts=$2 } ts >= (now - 86400)'|grep -iE "(youtube|discord)"|grep -vciE "(tutorial|piano)"
