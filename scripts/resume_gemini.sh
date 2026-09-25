#!/bin/bash
# Resume the Gemini annotation after the daily request quota resets (midnight Pacific =
# 10:00 Europe/Istanbul), then rebuild the label CSVs. Resume-safe; can be re-run.
cd "$(dirname "$0")/.." || exit 1
target=$(date -d "tomorrow 10:15" +%s); now=$(date +%s)
if [ "$target" -gt "$now" ]; then echo "waiting until $(date -d @$target) for the quota reset" ; sleep $((target - now)); fi
adac_annotate --provider gemini >> data/raw/gemini_run.log 2>&1
echo "gemini resume exit $?" >> data/raw/gemini_run.log
adac_annotate --export >> data/raw/gemini_run.log 2>&1
echo "GEMINI RESUME DONE $(date -u +%FT%TZ)" >> data/raw/gemini_run.log
