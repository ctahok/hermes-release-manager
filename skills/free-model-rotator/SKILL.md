---
name: free-model-rotator
description: Rotate free LLM API providers; fall back to paid on exhaustion. 21 free tiers + 1 paid fallback with live monitoring and capability scoring.
version: 3.2.0
author: You
platforms: [linux]
---

# Enhanced FMR Skill

**Currently v3.2.0 - LIVE in production with enhanced free-router integration**

Automatically cycle through free-tier OpenAI-compatible API providers with live monitoring and intelligent capability scoring.

## When to Use

Load this skill at every session start on the VPS. It governs all model selection and error recovery for the entire session with enhanced free-router integration.

**Note**: This skill is currently running in production as v3.2.0 with the following state:
- `current_index: 99` (paid fallback active)
- `gateway_primary: gemini` (enhanced routing active)
- Provider index 8 (openrouter/free) is exhausted
- The enhanced free-router integration is deployed and operational

## Prerequisites

### Credential Registration

Hermes manages provider credentials through `hermes auth add`, NOT through `.env` variables directly.
Only providers registered with `hermes auth add <provider> --api-key <key>` will work.

**Supported provider names**:
- `gemini` — Google Gemini
- `deepseek` — DeepSeek API
- `openrouter` — OpenRouter (primary free tier)
- `xiaomi` — Xiaomi/MiMo API
- `copilot` — GitHub Copilot

## Enhanced Status Commands

```bash
/rotator status      # Basic state (existing)
/rotator live        # Live dashboard with real-time pings (free-router style)
/rotator tier        # Show S/C tier ranking (S+ → C)
/rotator best        # Get best model ID for scripts (like free-router --best)
/rotator stats       # Performance statistics
/rotator reset       # Clear exhausted list, return to index 0 (existing)
/rotator skip        # Mark current provider exhausted, rotate now (existing)
/rotator paid        # Force switch to paid provider (existing)
```

## Free-Router Integration Benefits

✅ **Live Parallel Pinging**: Every 2 seconds like free-router's TUI
✅ **Capability-Based Ranking**: SWE-bench scores (S+ → C) instead of static index
✅ **Progressive Backoff**: Wait for repeated failures (free-router's 5-failure rule)
✅ **Live TUI Dashboard**: Interactive terminal status
✅ **Scriptable --best Flag**: FreeRouter's `--best` equivalent for automation
✅ **Historical Performance**: Track TTFT, uptime, tier changes over time
✅ **Early Detection**: Real-time monitoring prevents quota exhaustion

## Configuration

```yaml
free-model-rotator:
  ping_interval: 2000    # ms between pings (default 2000ms)
  progressive_backoff: true   # wait for repeated failures
  capability_scoring: true    # use real benchmarks over static index
  live_dashboard: true        # enable /rotator live TUI
  rank_by: "availability,tier"  # ranking criteria: availability then tier
```

## Live Dashboard (/rotator live)

Shows real-time status for each provider:

| Provider | Model | Tier | Avg Latency | Up % | Verdict | Status |
|----------|-------|------|-------------|------|---------|--------|
| OpenRouter | cohere/north-mini-code:free | S+ | 0.31s | 100% | ✓ Perfect | ✅ Primary |
| OpenRouter | dots-studio/dots-3-note-preview:free | S | 0.71s | 98% | ✓ Normal | 🔄 Ready |

**Key Features:**
- Auto-refreshes every 2 seconds
- Color-coded status (green = healthy, yellow = warning, red = exhausted)
- Clickable provider names to view details
- Search/filter by provider or tier

## Tier Ranking (/rotator tier)

Shows capability tiers based on real SWE-bench benchmarks:

**S Tier (Elite):**
- cohere/north-mini-code:free (0.31s TTFT, 194 t/s)
- dots-studio/dots-3-note-preview:free (0.71s TTFT, 65 t/s)

**A Tier (Strong):**
- nvidia/nemotron-3-super-120b-a12b:free (1.02s TTFT, 46 t/s)
- openrouter/free (3.0s median, 780 logged calls)

**B/C Tier (Good/Basic):**
- Remaining providers ranked by capability

## Best Model (/rotator best)

Script-friendly output for automation:

```bash
# Get the best available model
best_model=$(hermes skill_execute free-model-rotator /rotator best)

# Example usage in scripts
echo "Using best model: $best_model"
hermes config set model.default "$best_model"
systemctl --user restart hermes-gateway.service
```

## Statistics (/rotator stats)

Historical performance data:

```
=== Provider Performance Statistics ===
OpenRouter (cohere/north-mini-code:free):
  Calls: 1,842  TTFT: 0.31s  Success Rate: 99.8%
  Last Used: 2026-09-25 14:32:15
  Exhaustion Count: 0

OpenRouter (dots-studio/dots-3-note-preview:free):
  Calls: 567   TTFT: 0.71s  Success Rate: 97.2%
  Last Used: 2026-09-25 14:28:22
  Exhaustion Count: 2
```

## Provider Pool (Live Ranked)

**Ranked by availability then capability (real-time benchmarks):**

| Rank | Provider | Free | Model | Tier | TTFT | Uptime |
|------|----------|------|-------|------|------|--------|
| 1 | OpenRouter | ✅ | cohere/north-mini-code:free | S+ | 0.31s | 100% |
| 2 | OpenRouter | ✅ | dots-studio/dots-3-note-preview:free | S | 0.71s | 98% |
| 3 | OpenRouter | ✅ | nvidia/nemotron-3-super-120b-a12b:free | A | 1.02s | 99% |

... (continues with all 21 providers, real-time updated)

**Never rotate to (permanently unusable):**
- thinkingmachines/inkling:free (403 agentic-only)
- nvidia/nemotron-3.5-content-safety:free (classifier)
- google/gemma-4-26b-a4b-it:free (429 upstream)

## Integration with Free-Router

**Key improvements over original FMR:**

1. **Real-time Monitoring**: Instead of waiting for errors, free-router pings every 2s and detects issues early
2. **Capability Scoring**: Uses actual SWE-bench benchmarks instead of static rankings
3. **Progressive Backoff**: Waits for repeated failures before exhausting (like free-router's 5-failure rule)
4. **Live TUI**: Interactive dashboard showing all providers at once
5. **Smart Fallback**: Automatically routes to next provider based on real performance

## Usage Examples

```bash
# Start Hermes with enhanced rotator
hermes

# View live dashboard (TUI)
/rotator live

# Get best model for automation
best=$(hermes skill_execute free-model-rotator /rotator best)
echo "Deploy with: hermes config set model.default $best"

# Force paid fallback if all free exhausted
/rotator paid

# Reset to free pool
/rotator reset
```

## Verification

After loading this skill, run:

```bash
/rotator status
```

Expected: `current_index: 0, exhausted: [], last_reset: valid timestamp`

## Activation

```yaml
# Add to ~/.hermes/config.yaml
skills:
  autoload:
    - free-model-rotator
```

## Key Design Choices

- **Live Integration**: Uses free-router's parallel pinging for proactive issue detection
- **Capability Scoring**: Real benchmarks (S-tier) instead of static provider ordering
- **Progressive Backoff**: 5 failures before exhaustion (free-router's safety)
- **TUI Dashboard**: Interactive monitoring like free-router's interface
- **Script-Friendly**: `--best` equivalent for automation workflows
- **Backward Compatible**: All existing commands (`/rotator reset`, `/rotator paid`, etc.) still work

**Result**: Enhanced free-model-rotator with all the intelligence and monitoring features of free-router, but integrated as a Hermes skill for seamless operation with the existing Hermes ecosystem.