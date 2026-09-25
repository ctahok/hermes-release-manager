# MyBlinkist Cron Job Fix (Aug 2026)

## Problem
Cron job `73cad669d206` ("MyBlinkist Daily") failed with "main.py not found" — the entrypoint was wrong in the cron prompt.

## Root Cause
Cron prompt referenced `main.py` as entrypoint
Git history proved `main.py` **never existed** — the only Python file ever tracked was `scripts/download_blinkist.py`
The 13-08 run succeeded because the agent adapted; 14-08 failed because it followed the prompt literally
Separate issue: GitHub Actions workflow was removed (intentional GH→local migration) but had been auto-restored

## Fix Applied
1. **Updated cron prompt** (`cronjob action=update`) with correct entrypoint:
   - `scripts/venv/bin/python scripts/download_blinkist.py`
   - Added fallback: if path missing, list project files and find actual `.py` entrypoint
2. **Disabled GitHub Actions workflow** to prevent double-download race:
   - `mv .github/workflows/blinkist-daily.yml .github/workflows/blinkist-daily.yml.disabled`
   - Committed and pushed

## Verification
- Ran `scripts/download_blinkist.py` manually: downloaded today's book (18.3 MB), committed as `6607c1f`
- Cron job now correctly configured for 11:00 UTC daily
- Local Hermes cron is sole runner (per user preference for local over GH Actions)

## Key Lesson
**Cron prompts must match actual repo structure** — always verify entrypoint paths against git history before trusting a prompt. The agent's ability to adapt on 13-08 masked the bug; the 14-08 failure exposed it.