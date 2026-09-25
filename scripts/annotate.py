#!/usr/bin/env python
"""
scripts/annotate.py -- LLM annotation of data/bills_sample.csv (Section 5).

Design (manuscript/section5_data_plan.md): M = 3 models x P = 5 prompts x R = 3 runs at
temperature 0.7, plus a temperature-0 pass for prompt 1 only (one run per model).
Each call asks for a single digit; max_tokens = 16 for every provider; the FIRST digit in
the answer is parsed ("1"/"0"), one retry if the answer contains no 0/1, then recorded as
missing.

Providers (API keys from environment variables ONLY; never written to disk or logs):
  anthropic  ANTHROPIC_API_KEY  model claude-haiku-4-5-20251001 (public API endpoint)
  gemini     GEMINI_API_KEY     model gemini-3.5-flash, thinking disabled (override with GEMINI_MODEL; the served model_version is recorded)
  ollama     (local)            model qwen2.5:7b-instruct via http://localhost:11434
                                (model digest recorded in the output)

Outputs
  data/raw/<provider>.jsonl      every raw response: timestamp, model id, prompt id, run,
                                 temperature, raw text, parsed label, attempt, latency, usage
  data/labels_long.csv           parsed labels (temperature 0.7), one row per (bill, model, prompt, run)
  data/labels_temp0.csv          temperature-0 pass (prompt 1, one run per model)
Resume-safe: (bill, model, prompt, run, temperature) already in the jsonl are skipped.

Usage
  python scripts/annotate.py --provider anthropic --dry-run        # 20 items x 5 prompts x 1 run
  python scripts/annotate.py --provider gemini                     # full run (800 x 5 x 3 + temp-0 pass)
  python scripts/annotate.py --provider ollama --temp0-only
  python scripts/annotate.py --export                              # rebuild the two CSVs from raw/
"""
import argparse, csv, json, os, re, sys, time, hashlib
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLE = ROOT / "data" / "bills_sample.csv"
RAW_DIR = ROOT / "data" / "raw"
PROMPTS = {
    1: 'Is the following US congressional bill primarily about health? Bill title: "{TITLE}"\nAnswer with a single digit: 1 for yes, 0 for no.',
    2: 'You are coding US congressional bills by policy topic using the Comparative Agendas Project scheme. The topic "Health" (code 3) covers health care, health insurance, drugs and pharmaceuticals, medical facilities, mental health, disease prevention and health research. Does the bill below belong to this topic as its main subject?\nTitle: "{TITLE}"  Reply 1 (yes) or 0 (no) only.',
    3: 'A bill\'s main subject can be health, or one of twenty other policy areas such as the economy, defence, education, the environment or law. Consider the title and decide whether its main subject is health.  "{TITLE}"  Output only 1 or 0.',
    4: 'As an experienced legislative analyst, classify this bill title. Output 1 if the bill\'s primary purpose concerns health policy, 0 otherwise. Title: "{TITLE}"',
    5: 'Read the bill title and think about its primary policy purpose, then decide whether that purpose falls under health. Do not write your reasoning. Reply with the final digit only: 1 = health, 0 = not health. Title: "{TITLE}"',
}
MODELS = {
    "anthropic": "claude-haiku-4-5-20251001",
    "gemini": os.environ.get("GEMINI_MODEL", "gemini-3.5-flash"),   # GA Flash reachable with the project key; thinking disabled; served model_version recorded
    "ollama": "qwen2.5:7b-instruct",
}
MAX_TOKENS = 16      # all providers; the first digit of the answer is parsed (author's decision, 25 Sept 2026)
TEMPERATURE = 0.7
RUNS = 3
# polite rate limits (seconds between calls) and retry policy for transport errors
MIN_INTERVAL = {"anthropic": 0.12, "gemini": 0.35, "ollama": 0.0}   # global spacing between call starts (all workers)
TRANSPORT_RETRIES = 6

def log(msg):
    print(f"[annotate {datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)

def parse_digit(text):
    """The first digit character in the answer, if it is 0 or 1; otherwise None (triggers one retry)."""
    if text is None: return None
    m = re.search(r"[0-9]", text)
    return int(m.group(0)) if m and m.group(0) in "01" else None

# ---------------------------------------------------------------- providers
class Anthropic:
    name = "anthropic"
    def __init__(self):
        import anthropic
        key = os.environ.get("ANTHROPIC_API_KEY")
        if not key: sys.exit("ANTHROPIC_API_KEY not set")
        # use the public endpoint explicitly (the shell may carry a proxy base URL)
        # keys that are not scoped to a workspace need the anthropic-workspace-id header
        hdr = {"anthropic-workspace-id": os.environ["ANTHROPIC_WORKSPACE_ID"]} if os.environ.get("ANTHROPIC_WORKSPACE_ID") else None
        self.client = anthropic.Anthropic(api_key=key, base_url="https://api.anthropic.com", default_headers=hdr)
        self.model_id = MODELS["anthropic"]
        self.version_info = {"sdk": anthropic.__version__}
    def call(self, prompt, temperature):
        # anthropic SDK 1.x removed the temperature keyword; Haiku 4.5 still honours it via the request body
        r = self.client.messages.create(model=self.model_id, max_tokens=MAX_TOKENS,
                                        messages=[{"role": "user", "content": prompt}],
                                        extra_body={"temperature": temperature})
        text = "".join(b.text for b in r.content if getattr(b, "type", "") == "text")
        usage = {"input_tokens": r.usage.input_tokens, "output_tokens": r.usage.output_tokens}
        return text, usage, r.model

class Gemini:
    name = "gemini"
    def __init__(self):
        from google import genai
        from google.genai import types
        key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
        if not key: sys.exit("GEMINI_API_KEY not set")
        self.client = genai.Client(api_key=key)
        self.types = types
        self.model_id = MODELS["gemini"]
        import google.genai as g
        # record which Flash models the API currently lists (model id verification)
        try:
            flash = sorted(m.name.replace("models/", "") for m in self.client.models.list() if "flash" in m.name)
        except Exception as e:
            flash = [f"models.list failed: {type(e).__name__}"]
        self.version_info = {"sdk": g.__version__, "flash_models_listed": flash[:20]}
    def call(self, prompt, temperature):
        cfg = self.types.GenerateContentConfig(temperature=temperature, max_output_tokens=MAX_TOKENS,
                                               thinking_config=self.types.ThinkingConfig(thinking_budget=0))
        r = self.client.models.generate_content(model=self.model_id, contents=prompt, config=cfg)
        text = r.text if r.text is not None else ""
        um = getattr(r, "usage_metadata", None)
        usage = {"input_tokens": getattr(um, "prompt_token_count", None), "output_tokens": getattr(um, "candidates_token_count", None)} if um else {}
        mv = getattr(r, "model_version", None) or self.model_id
        return text, usage, mv

class Ollama:
    name = "ollama"
    def __init__(self):
        import requests
        self.requests = requests
        self.base = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
        self.model_id = MODELS["ollama"]
        info = requests.post(f"{self.base}/api/show", json={"name": self.model_id}, timeout=60)
        info.raise_for_status()
        d = info.json()
        tags = requests.get(f"{self.base}/api/tags", timeout=60).json().get("models", [])
        digest = next((m.get("digest") for m in tags if m.get("name") == self.model_id), None)
        self.digest = digest
        self.version_info = {"ollama_version": requests.get(f"{self.base}/api/version", timeout=60).json().get("version"),
                             "digest": digest, "parameter_size": d.get("details", {}).get("parameter_size"),
                             "quantization": d.get("details", {}).get("quantization_level")}
    def call(self, prompt, temperature):
        r = self.requests.post(f"{self.base}/api/generate", timeout=600, json={
            "model": self.model_id, "prompt": prompt, "stream": False,
            "options": {"temperature": temperature, "num_predict": MAX_TOKENS, "seed": int(time.time_ns() % 2**31)}})
        r.raise_for_status(); d = r.json()
        usage = {"input_tokens": d.get("prompt_eval_count"), "output_tokens": d.get("eval_count")}
        return d.get("response", ""), usage, f"{self.model_id}@{self.digest}"

PROVIDERS = {"anthropic": Anthropic, "gemini": Gemini, "ollama": Ollama}

# ---------------------------------------------------------------- driver
def load_sample():
    with open(SAMPLE, newline="") as f:
        return list(csv.DictReader(f))

def done_keys(path):
    keys = set()
    if path.exists():
        with open(path) as f:
            for line in f:
                try:
                    d = json.loads(line)
                    if d.get("final"): keys.add((d["bill_id"], d["prompt"], d["run"], d["temperature"]))
                except json.JSONDecodeError:
                    pass
    return keys

import threading
from concurrent.futures import ThreadPoolExecutor, as_completed

class Pacer:
    """Global minimum interval between call starts, shared by all workers."""
    def __init__(self, interval): self.interval = interval; self.lock = threading.Lock(); self.t_next = 0.0
    def wait(self):
        with self.lock:
            now = time.time(); t = max(now, self.t_next); self.t_next = t + self.interval
        if t > now: time.sleep(t - now)

def annotate_one(P, provider_name, pacer, it, p, r, temperature):
    """One (bill, prompt, run): up to two attempts; returns the list of records written."""
    prompt = PROMPTS[p].replace("{TITLE}", it["title"])
    recs = []
    for attempt in (1, 2):                           # one retry on a non-digit answer
        text, usage, model_version, err, lat = None, {}, None, None, None
        for tr in range(TRANSPORT_RETRIES):          # transport / rate-limit errors: backoff
            pacer.wait()
            try:
                t0 = time.time(); text, usage, model_version = P.call(prompt, temperature); lat = time.time() - t0
                err = None; break
            except Exception as e:                    # never log secrets: only the exception class + short message
                err = f"{type(e).__name__}: {str(e)[:160]}"
                time.sleep(min(60, 2 ** tr))
        label = parse_digit(text)
        recs.append({"ts": datetime.now(timezone.utc).isoformat(timespec="seconds"), "provider": provider_name,
                     "model_id": P.model_id, "model_version": model_version, "bill_id": it["bill_id"],
                     "prompt": p, "run": r, "temperature": temperature, "attempt": attempt,
                     "raw": text, "label": label, "latency_s": round(lat, 3) if lat else None,
                     "usage": usage, "error": err, "final": (label is not None) or attempt == 2})
        if label is not None: break
    return recs

def run(provider_name, items, prompts, runs, temperature, dry_run=False, workers=1):
    P = PROVIDERS[provider_name]()
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    path = RAW_DIR / (f"{provider_name}{'_dryrun' if dry_run else ''}.jsonl")
    done = done_keys(path)
    todo = [(it, p, r) for it in items for p in prompts for r in range(1, runs + 1)
            if (it["bill_id"], p, r, temperature) not in done]
    log(f"{provider_name} {P.model_id} {P.version_info}: {len(todo)} calls to do ({len(done)} already done), "
        f"{workers} worker(s) -> {path.name}")
    n_ok = n_missing = 0; tot_in = tot_out = 0; k = 0
    pacer = Pacer(MIN_INTERVAL[provider_name])
    with open(path, "a") as out, ThreadPoolExecutor(max_workers=workers) as ex:
        futs = [ex.submit(annotate_one, P, provider_name, pacer, it, p, r, temperature) for it, p, r in todo]
        for fut in as_completed(futs):
            recs = fut.result(); k += 1
            for rec in recs:                          # single writer thread
                out.write(json.dumps(rec, ensure_ascii=False) + "\n")
                tot_in += (rec["usage"] or {}).get("input_tokens") or 0; tot_out += (rec["usage"] or {}).get("output_tokens") or 0
            out.flush()
            if recs[-1]["label"] is None: n_missing += 1
            else: n_ok += 1
            if k % 100 == 0 or k == len(todo):
                log(f"{provider_name}: {k}/{len(todo)} done, parsed {n_ok}, missing {n_missing}, tokens in/out {tot_in}/{tot_out}")
    return n_ok, n_missing, tot_in, tot_out

def export():
    """Rebuild labels_long.csv (temperature 0.7) and labels_temp0.csv from the raw files."""
    rows = {}
    for path in sorted(RAW_DIR.glob("*.jsonl")):
        if "dryrun" in path.name: continue
        with open(path) as f:
            for line in f:
                d = json.loads(line)
                key = (d["bill_id"], d["provider"], d["prompt"], d["run"], d["temperature"])
                prev = rows.get(key)
                if prev is None or (prev["label"] is None and d["label"] is not None) or d["attempt"] > prev["attempt"]:
                    rows[key] = d
    def write(fn, temp):
        with open(fn, "w", newline="") as f:
            w = csv.writer(f); w.writerow(["bill_id", "model", "model_id", "prompt", "run", "temperature", "label", "missing"])
            for key in sorted(rows):
                d = rows[key]
                if d["temperature"] != temp: continue
                w.writerow([d["bill_id"], d["provider"], d["model_version"] or d["model_id"], d["prompt"], d["run"],
                            d["temperature"], "" if d["label"] is None else d["label"], int(d["label"] is None)])
    write(ROOT / "data" / "labels_long.csv", TEMPERATURE)
    write(ROOT / "data" / "labels_temp0.csv", 0.0)
    log(f"exported {sum(1 for d in rows.values() if d['temperature'] == TEMPERATURE)} labels (T=0.7) and "
        f"{sum(1 for d in rows.values() if d['temperature'] == 0.0)} (T=0)")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", choices=list(PROVIDERS))
    ap.add_argument("--dry-run", action="store_true", help="20 items x 5 prompts x 1 run, written to <provider>_dryrun.jsonl")
    ap.add_argument("--temp0-only", action="store_true", help="only the temperature-0 pass (prompt 1, one run)")
    ap.add_argument("--export", action="store_true")
    ap.add_argument("--workers", type=int, default=None, help="parallel workers (default: anthropic 4, gemini 2, ollama 1)")
    a = ap.parse_args()
    if a.export:
        export(); sys.exit(0)
    if not a.provider: ap.error("--provider required")
    items = load_sample()
    workers = a.workers or {"anthropic": 4, "gemini": 2, "ollama": 1}[a.provider]
    if a.dry_run:
        n_ok, n_miss, ti, to = run(a.provider, items[:20], list(PROMPTS), 1, TEMPERATURE, dry_run=True, workers=workers)
        log(f"DRY RUN {a.provider}: parsed {n_ok}/{n_ok + n_miss}, tokens in/out {ti}/{to}")
    else:
        if not a.temp0_only:
            run(a.provider, items, list(PROMPTS), RUNS, TEMPERATURE, workers=workers)
        run(a.provider, items, [1], 1, 0.0, workers=workers)
        export()
