#!/bin/bash
# Full annotation run: API providers in parallel, the local Ollama model last (it is the
# slowest and must not compete with the API calls), then export of the label CSVs.
# Resume-safe: re-running skips (bill, prompt, run, temperature) already in data/raw/.
# Requires ~/.config/adac/keys.env (user-owned) and a running Ollama server.
set -u
cd "$(dirname "$0")/.." || exit 1
mkdir -p data/raw
adac_annotate --provider anthropic > data/raw/anthropic_run.log 2>&1 &
PA=$!
adac_annotate --provider gemini    > data/raw/gemini_run.log 2>&1 &
PG=$!
wait $PA; echo "anthropic exit $?" >> data/raw/anthropic_run.log
wait $PG; echo "gemini exit $?"    >> data/raw/gemini_run.log
adac_annotate --provider ollama    > data/raw/ollama_run.log 2>&1
echo "ollama exit $?" >> data/raw/ollama_run.log
adac_annotate --export >> data/raw/ollama_run.log 2>&1
echo "ALL DONE $(date -u +%FT%TZ)" >> data/raw/ollama_run.log
