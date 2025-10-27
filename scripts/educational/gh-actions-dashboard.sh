#!/bin/bash
# gh-actions-dashboard.sh
# Live dashboard for GitHub Actions workflow run steps
# Usage: ./gh-actions-dashboard.sh <run_id>

if [ -z "$1" ]; then
  echo "Usage: $0 <workflow_run_id>"
  exit 1
fi

RUN_ID="$1"

while true; do
  clear
  echo "GitHub Actions Workflow Step Status (Run ID: $RUN_ID)"
  echo "---------------------------------------------------------"
  gh run view "$RUN_ID" --json jobs --jq \
    '.jobs[] | "\(.name):\n" + ([.steps[] | "  \(.name)\t\(.status)"] | join("\n"))' | column -t -s $'\t'
  sleep 5
done
