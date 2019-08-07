#!/bin/bash
# Remove non-data lines so that file can be passed to GNUPlot

if [ "$#" -ne 1 ]; then
  echo "Usage: script <filename>"
  exit 1
fi

tail -n +10 "$1" | head -n -3