# Starred-Projects Deployment Plan

**Source:** all **763** publicly visible starred repos of [@qunewsguy16](https://github.com/qunewsguy16), pulled 2026-07-31 and individually classified (763/763 coverage, machine-verified — no sampling). GitHub's profile counter reports 770 stars; the 7 not captured no longer render on the public stars pages (repos deleted or made private) and could not be classified. Full per-repo classification: [deployment/ANALYSIS.md](deployment/ANALYSIS.md). Skills install assets: [deployment/skills/](deployment/skills/). Human-action queue: [WIZARD.md](WIZARD.md).

**Standing rule this plan encodes:**
> **NAS (DS423+) = always-on orchestration, storage, webhooks. PC (RTX desktop) = everything that touches CUDA. Cloud = free tiers you consume, not servers you run. Skills = installed into desktop Claude Code, curated — not hoarded.**

**Classification totals:** 78 NAS · 170 PC · 13 cloud · 97 skills · 9 multi-target · 234 reference · 162 skip

---

# Part 1 — Synology DS423+ Deployment Plan

**Hardware reality check (verified against the DS423+ spec sheet):** Celeron J4125 — 4 cores, **no AVX** (some ML/media images need generic builds), no listed hardware-transcode engine (QuickSync via `/dev/dri` passthrough is best-effort only), ~6GB RAM shared with DSM (~1GB) and the existing stack (Plex etc.). Realistic headroom for new containers: **~2.5–3GB**. Rule of thumb below: deploy Tier 1, watch Netdata, then add Tier 2/3 one stack at a time. Keep each stack as a compose project under `/volume1/docker/<stack>/` so Container Manager and the CLI stay in sync.

---

## 1. TOP PICKS — deploy first

### Tier 1 — Infrastructure (do these in one afternoon; ~400MB total)

| Repo | What / why | Deploy hint | RAM |
|---|---|---|---|
| `louislam/dockge` | Compose-file-first stack manager over Tailscale — upgrades every other deployment on this list vs. DSM Container Manager. | `louislam/dockge:1`, mount `/volume1/docker` as stacks dir | ~80MB |
| `caronc/apprise-api` | Single notification endpoint for ralph loops, NAS jobs, HA automations — pairs with the `apprise` CLI in Claude Code hooks on the PC. | `caronc/apprise-api:latest`, one port, done | ~50MB |
| `netdata/netdata` | Live CPU/RAM/container visibility — this is the gauge that tells you whether the next service fits in 6GB. | `netdata/netdata` with ML/retention tuned down | ~250MB |
| `containrrr/watchtower` (deploy the active fork) | Automated image-update story for a 24/7 box. | `nicholas-fedor/watchtower`, **notify-only mode** (via apprise-api) so nothing breaks Plex overnight | ~20MB |

### Tier 2 — Project wins (the reason the NAS exists; ~2GB total, stage them)

| Repo | What / why | Deploy hint | RAM |
|---|---|---|---|
| `glanceapp/glance` | This IS his stated news/RSS dashboard project — single Go binary, one YAML. Easiest high-value win in the batch. | `glanceapp/glance`, one `glance.yml` | ~25MB |
| `paperless-ngx/paperless-ngx` | Searchable OCR archive of bills/statements/genealogy scans — feeds envelope-budget, debt tracking, AND family research. Strongest single add. | Official compose (app + Redis, SQLite fine at household volume); OCR is slow on J4125 but fine | ~800MB–1GB |
| `hail2victors/n8n-Actual-Automation` | His envelope-budgeting project pre-built: Actual Budget + AI categorization + envelope auto-funding + weekly briefing. | `actualbudget/actual-server` (~100MB) + `n8nio/n8n` single-instance SQLite mode (~350MB); import the six workflows | ~450MB |
| `gramps-project/gramps-web` | Active genealogy hobby → family tree browsable/editable anywhere, shareable with relatives over Tailscale; syncs with desktop Gramps. | `ghcr.io/gramps-project/grampsweb` + Redis/Celery; skip the optional AI-chat features | ~400MB |

### Tier 3 — Agent + media building blocks (~600MB, add after Tier 2 settles)

| Repo | What / why | Deploy hint | RAM |
|---|---|---|---|
| `openclaw/openclaw` | Always-on personal-agent gateway (messaging → Claude) — the 24/7 layer his memory architecture is missing; inference is API-side. | Node/TS container; **lock down auth/pairing, tailnet-only** — known foot-guns on exposed instances | ~250MB |
| `searxng/searxng` | Free web-search backend for self-hosted agents + news monitoring — a building block, not just an app. | `searxng/searxng`, tailnet-only | ~250MB |
| `sissbruecker/linkding` | Bookmark capture with a REST API his Claude agents and Obsidian can read. Textbook DS423+ citizen. | `sissbruecker/linkding` (SQLite) | ~60MB |
| `imputnet/cobalt` | Clean web UI over the yt-dlp-style grabbing he already does; also handy for reference video at work. | Official compose, tailnet-only | ~150MB |

---

## 2. NEXT WAVE — deploy when the trigger condition hits

- **`home-assistant/core`** — HA Container (~1GB) when he's ready to consolidate the smart-home hub onto the NAS; Docker install, no Supervisor, Tailscale covers remote access. Biggest single RAM ask in this wave — check Netdata first.
- **`seerr-team/seerr`** + **`linuxserver/docker-sonarr`** — the household request UI + canonical *arr for the Plex stack (~300MB combined).
- **`Kometa-Team/Kometa`** — Plex collections/overlays as an overnight scheduled container.
- **`DialmasterOrg/Youtarr`** — scheduled yt-dlp channel archiving into Plex (cobalt covers ad-hoc; this covers cron).
- **`chrisbenincasa/tunarr`** — his own 24/7 linear channel with his own interstitials between shows: peak promo-producer energy. Direct-play-friendly channel configs only; treat QuickSync as a bonus, not a plan.
- **`HaveAGitGat/Tdarr`** — **server/UI only** on the NAS; the transcode node goes on the PC (see §4).
- **`seanmorley15/AdventureLog`** — travel-planning winner (see dedupes); Django+Postgres, fine on the box.
- **`wger-project/wger`** — fitness tracking winner; light Django app.
- **`TandoorRecipes/recipes`** — meal planning that feeds both fitness tracking and grocery-envelope discipline.
- **`advplyr/audiobookshelf`** — he's an Audible listener; trivial, low-RAM, classic NAS citizen.
- **`clusterzx/paperless-ai`** — LLM auto-tagging add-on **after** Paperless-ngx is settled; point at a cloud LLM API, never local models.
- **`kenn-io/msgvault`** — Gmail/IMAP archive with MCP endpoint for genealogy/memory work; light Go+SQLite daemon, but alpha — keep originals.
- **`adnanh/webhook`** — near-zero-RAM glue when he wants phone/HA/GitHub triggers running NAS scripts.
- **`StevenBlack/hosts`** — as the blocklist source for an AdGuard Home container (network-wide DNS filtering; better than PC hosts-file edits).
- **`nocodb/nocodb`** — general structured-data layer (genealogy tables, debt tracking) if Paperless+Actual leave a gap; watch RAM.
- **`rommapp/romm`** — retro-game library with client-side EmulatorJS; fun-tier, fits fine.
- **RAM-gated borderliners** (~1GB+ each — only after Netdata shows sustained headroom, realistically after trimming something else): `Infisical/infisical` (cloud free tier is the fallback), `gitroomhq/postiz-app` (personal/side-channel social scheduling; WFSB accounts stay on Gray tooling), `khoj-ai/khoj` (cloud LLM APIs only; pgvector adds pressure), `tess1o/geopulse` (Quarkus+Postgres, ~1GB), `open-webui/open-webui` (UI only; inference on PC/API).
- **Watch, don't deploy:** `MoldyTaint/Cinephage` (revisit in 6–12 months vs. the *arr stack), `shumaiOne/shumai` (self-hosted Frame.io is genuinely useful for promo review links, but video review needs proxies/transcode — pilot it on the PC first, promote to NAS only if direct-play proxies work), `tinyauthapp/tinyauth` + `certimate-go/certimate` (the day something goes beyond the tailnet).

---

## 3. DEDUPE DECISIONS

| Category | Contenders (starred) | Winner | Why |
|---|---|---|---|
| Compose/stack manager | dockge, dockhand, sencho, (Portainer) | **dockge** | Most mature of the lightweight tier (Uptime Kuma author); keeps stacks as plain `compose.yaml` on disk — zero lock-in, agent-editable over SSH. dockhand/sencho are younger takes on the same idea. |
| Notifications | apprise-api, gotify, hark, (ntfy) | **apprise-api** | One endpoint that fans out to 100+ services incl. ntfy/Telegram — so the choice of phone app stays reversible. Gotify is fine but Android-only ecosystem; hark is a smaller re-solve. |
| Bookmarks/read-later | linkding, linkwarden | **linkding** | Tiny SQLite container with a clean REST API for agent automation. Linkwarden's Playwright full-page archiver is the heavy part — wrong tradeoff on a J4125. Revisit only if link-rot preservation becomes a real need. |
| Workflow automation | n8n, activepieces, automatisch, Budibase | **n8n** | He has an n8n skill and the Actual-Budget workflows are built for it. Second platforms add maintenance, not capability. n8n = deterministic plumbing; Claude Code Routines = agentic work. |
| Genealogy | gramps-web, webtrees | **gramps-web** | Gramps-native sync with desktop Gramps beats webtrees' GEDCOM round-tripping. Reconsider only if Gramps Web collaboration disappoints. |
| Travel | AdventureLog, trip, geopulse, dawarich | **AdventureLog** | Active planning + itineraries + logging in one, family-shareable. `trip` is a subset; geopulse (passive timeline) is complementary but RAM-gated; **dawarich rejected** — Rails+Postgres+Redis+Sidekiq is one of the heaviest stacks in the batch for the same job geopulse does lighter. |
| Fitness | wger, workout-cool, SparkyFitness | **wger** | Most mature tracker and covers nutrition/body-weight too. workout-cool is direct overlap. SparkyFitness only re-enters if family food-logging becomes the actual use case. |
| News/RSS dashboards | glance, situation-monitor, worldmonitor, news-dashboard, makhalReader | **glance** (NAS) + **worldmonitor** (PC desktop build) | glance is the 20MB always-on dashboard; worldmonitor's Vercel-edge architecture makes the Tauri PC app its natural home, not a NAS container. situation-monitor/news-dashboard/makhalReader re-solve slices of the same itch — skip until glance proves insufficient. |
| Plex collections | Kometa, agregarr | **Kometa** | Established standard; agregarr is lighter but narrower. One overnight scheduled container either way — take the ecosystem. |
| Linear TV / IPTV | tunarr, ffplayout, Dispatcharr | **tunarr** | dizqueTV successor built exactly for "channels from your Plex library." ffplayout is a broadcast playout engine (cool, but a second system); Dispatcharr only matters if external IPTV sources appear. |
| Podcasts | audiobookshelf, podgrab | **audiobookshelf** | podgrab unmaintained since ~2022; Audiobookshelf does audiobooks + podcasts in one maintained app. |
| Search/answer engines | searxng, Vane, open-webui | **searxng** now | It's the building block the others sit on. Vane bundles SearXNG+LLM chat — redundant once searxng exists and Claude covers answers; open-webui is the RAM-gated family-chat option later. |
| Media manager consolidation | *arr stack (sonarr et al.), Cinephage | ***arr stack** | Never migrate a working stack to a pre-1.0 all-in-one. Cinephage goes on the watch list. |
| ROM managers | romm, gaseous-server | **romm** | Python+small DB vs .NET+MariaDB; romm is the better NAS citizen and EmulatorJS runs client-side. |
| Notes/wiki | docmost (vs. Obsidian) | **no deployment** | His PKM is Obsidian and won't move; docmost only if a real multi-user doc need appears. `Nystik-gh/ignis` (Obsidian-in-browser) is the only Obsidian-adjacent candidate — trial it, but containerized Obsidian is RAM-hungry and sync-conflict-prone; measure before keeping. |
| Network map | scanopy, (homelable) | **scanopy** if at all | Self-updating; cute but non-essential at this network's size. |

---

## 4. DO-NOT-RUN-ON-NAS

| Repo | Why not this box | Where it belongs |
|---|---|---|
| `immich-app/immich` | Postgres+Redis+ML on a box officially maxed at 6GB shared with Plex — the ML container alone eats the headroom, and no-AVX complicates ML images. | On hold, or NAS **only** with ML fully disabled after Netdata confirms ~1.5GB sustained headroom. It's the flagship reason a future dedicated mini-PC exists. |
| `blakeblackshear/frigate` | CPU object detection is unusably slow on a J4125; he owns no cameras today anyway. | If cameras happen: NAS + **Coral USB TPU** (decode of 1–2 cams is fine), or a small dedicated box. |
| `HaveAGitGat/Tdarr` (worker) | Never transcode on the J4125 — the spec sheet lists no transcode engine and QuickSync passthrough is best-effort. | Server/UI on NAS; **transcode node on the Windows PC** using NVENC/AV1. The classic split for his exact hardware. |
| `NeptuneHub/AudioMuse-AI` | Sonic analysis would churn for days on 4 Celeron cores; targets Jellyfin/Navidrome, not Plex. | PC as an overnight batch job — and only after verifying Plex support. |
| `getmaxun/maxun` | Postgres+MinIO+Redis+headless-browser workers; browsers on a J4125 crawl. | PC, or just write crawlee scripts with Claude. |
| `LibreTranslate/LibreTranslate` | 1–2GB RAM for translation quality well below what he already gets from Claude. | Skip; PC if a fully-offline subtitle pipeline ever matters. |
| Local LLM inference (Ollama, Khoj/open-webui/Vane local modes, paperless-ai local) | No GPU, no AVX guarantees, 6GB RAM — non-starter. | Inference on the **PC's NVIDIA GPU** when it's awake, or cloud APIs; NAS hosts UIs/gateways only. |
| `koala73/worldmonitor` | Vercel-edge-function architecture fights a NAS deployment. | Tauri desktop app on the PC; Vercel free tier for anywhere-access. |
| `paperboytm/spool` | Not a NAS container at all — CLI + Cloudflare Workers hub. | PC (CLI) + Cloudflare Workers free tier. Shared sessions are public by default: keep station work out. |
| `googleworkspace/cli` | Nothing to host — it's a CLI + Agent Skills. | PC, inside desktop Claude Code (high priority there — it upgrades the Drive `_STATE` memory-ops workflow directly). |
| `go-gitea/gitea` | Not heavy, just redundant — GitHub free private repos cover the need. | Only revisit as an automated backup mirror target for the skill library/mods. |
| `Crosstalk-Solutions/project-nomad` | Wikipedia dumps are storage-hungry and it advances nothing active; the local-AI option is a hard no. | Fun weekend project someday; skip the AI component regardless. |

**Operating rule:** after Tier 1, every subsequent deploy is gated by `free -m` / Netdata showing the headroom, and every stack lives in `/volume1/docker/<stack>/docker-compose.yml` so both DSM and Claude-over-SSH can manage it.

---

# Part 2 — Windows Desktop PC Deployment List
*NVIDIA GPU box: desktop Claude Code, After Effects, CS2. Curated for maximum WFSB promo throughput and restoration-hobby leverage.*

---

## 1. TOP PICKS

### A. Broadcast / Promo Production (day-job accelerators)

| Repo | What / Why | Install |
|---|---|---|
| **inlife/nexrender** | Data-driven, unattended AE rendering — topicals, weather updates, localized spots versioned from JSON jobs. The single most job-relevant repo in the batch. Pair with a Claude Code skill that emits nexrender job JSON. | `npm i -g nexrender-cli` (needs aerender on PATH) |
| **forticheprod/py-aep** | Python read/edit of `.aep` files — lets Claude Code batch-version daily promo projects directly. Verify write coverage of the RIFX format before building workflows on it. | `pip install py-aep` |
| **Comfy-Org/ComfyUI** | Promo concept art, texture/element generation for AE, upscaling chains, video-model experiments — node workflows are JSON, so Claude Code can author them. The most useful local-AI install for the actual job. | Portable Windows zip or `git clone` + venv |
| **IliasHad/edit-mind** | Whisper + frame analysis + ChromaDB semantic search over footage — the promo producer's archive-search problem, and it mirrors his own chromadb/ffmpeg/FTS5 skill stack. Equal parts deploy and design reference. | CUDA Docker compose (Docker Desktop) |
| **calesthio/OpenMontage** | Claude-Code-driven video production: 12 pipelines, 700+ skill files. Even if pipelines underwhelm, the skill corpus is mineable for his own production skills. | `git clone` + `make setup` |
| **ronak-create/FableCut** | Agent-drivable browser NLE — JSON timeline + MCP + REST. Claude Code assembles rough cuts and social edits directly. Trial on a social cut this week. | `git clone` + `node server.js` (ffmpeg on PATH) |
| **WyattBlue/auto-editor** | Auto-cuts silence from interviews/VO before Premiere/AE; exports Premiere XML. Drops straight into the ffmpeg pipeline. | `pip install auto-editor` |
| **nolangz/pixel2motion** | Junk raster sponsor logos → SVG + auto-animation, feeding the AE pipeline. Even mediocre vectorization beats manual tracing. | git clone / per-repo instructions |
| **Scratch-VO pair: QwenLM/Qwen3-TTS + kyutai-labs/pocket-tts** | Read a :30 script in a credible voice before talent records. Qwen3-TTS = GPU quality; pocket-tts = instant CPU output while AE/renders own the GPU. Scratch use only — never air synthetic VO. | pip per repo |
| **openai/CLIP** (via open_clip) | CLIP embeddings + his existing ChromaDB skill = semantic search over promo footage and archive frames. Buildable this month. | `pip install open_clip_torch` |

### B. Video Restoration (VapourSynth stack + upscalers)

| Repo | What / Why | Install |
|---|---|---|
| **pifroggi/vs_deepdeinterlace** | SOTA AI deinterlacing — the first and most important pass on archival broadcast tape. Anchor of the suite; install first. | git clone into VapourSynth plugins + pip deps |
| **pifroggi suite** (vs_colorfix, vs_temporalfix; vs_align/vs_tiletools/vs_undistort as needed) | Color transfer against reference copies, temporal coherence for AI upscales (the #1 shimmer fix), alignment/tiling/dewarp utilities. Clone alongside, per the vapoursynth-stuff index. | git clone each module |
| **StuartCameronCode/VapourBox** | GUI front-end for the VapourSynth restoration chain (deinterlace, upscale, color). Check which filters it wraps (QTGMC etc.) against the existing script chain. | installer / git per repo |
| **upscayl/upscayl** | Zero-config Real-ESRGAN GUI for stills: archival frames, low-res station art, scanned genealogy photos. Images only — video stays in VapourSynth. | `winget install Upscayl.Upscayl` |
| **haoheliu/versatile_audio_super_resolution** (AudioSR) | Archival tape transfers need audio restoration as much as deinterlacing; upscales any audio to 48 kHz. | `pip install audiosr` |
| **Uranite/xav** | Chunked target-quality AV1 encoding (Av1an/ab-av1 mold) for restoration output masters. Compare against Av1an before standardizing. | release binary / cargo |

### C. AI / Agent Tooling (local)

| Repo | What / Why | Install |
|---|---|---|
| **gastownhall/gastown** | Yegge's multi-agent workspace manager (Mayor, persistent polecats, worktrees, Beads) — the flagship for exactly his ralph-loop/orchestration practice. Could replace much of the hand-rolled harness. | WSL2: Go + tmux + Beads; trial on one repo first |
| **volcengine/OpenViking** | His memory architecture productized: unified agent memory/knowledge/skills as a viking:// FS with tiered L0/L1/L2 loading, MCP into Claude Code out of the box. Evaluate *against* the _STATE/Obsidian system, not beside it. | `pip install` (local-first, light) |
| **8ddieHu0314/Skill-Lab** | Linter/security-scanner/trigger-tester for Agent Skills (37 checks, Claude-first). Directly on the critical path of maintaining his skill library. Wire into skill-creator. | `pip install` (Python 3.10+) |
| **googleworkspace/cli** | First-class scripted Drive/Gmail/Calendar access — his _STATE docs live in Drive, so this upgrades memory-ops without MCP plumbing. 100+ bundled Agent Skills. Pre-1.0, moving fast. | npm / binary + OAuth |
| **ohad6k/emulo** | Mines Claude Code session logs into an evidence-backed you.md profile — exactly the input his procedural-memory-distillation skill wants. Run where the logs live. | `pip install emulo` |
| **promptfoo/promptfoo** | Regression tests for skill prompts before they rot; he ships skills with no systematic eval today. | `npm i -g promptfoo` |
| **rtk-ai/rtk** | Compacts common dev-command output 60-90% before it hits the model — near-zero-effort win for ralph loops. Measure before/after. | binary / alias into Claude Code hooks |

### D. CS2 Modding Aids

Thin batch for CS2 — the game is C#, so dnSpy/ILSpy (already in his kit) remain the decompiler lane; Ghidra/x64dbg are for native curiosity only.

| Repo | What / Why | Install |
|---|---|---|
| **oven-sh/bun** | Fast JS runtime/bundler for CS2 UI-mod toolchains (Coui/webpack builds) and general script running. Install alongside Node, not replacing it. | `winget install Oven-sh.Bun` |
| **lightningpixel/modly** | Image-to-3D for custom CS2 assets and motion-design props — experiment tier, not broadcast-ready. | installer per repo |
| *(Watch: colbymchenry/codegraph, Egonex-AI/Understand-Anything)* | Code knowledge graphs — only worth it if he starts navigating decompiled CS2 assemblies at scale. | — |

### E. General Utilities

| Repo | What / Why | Install |
|---|---|---|
| **gitleaks/gitleaks** | Pre-commit secret scanning across many personal repos juggling API keys — ten-minute install preventing his most likely serious mistake. | `winget install Gitleaks.Gitleaks` + pre-commit hook |
| **winsiderss/systeminformer** | Best-in-class Task Manager replacement for a box running AE renders, encodes, and AI jobs simultaneously. | `winget install WinsiderSS.SystemInformer` |
| **astral-sh/ruff** | Instant lint/format for skill scripts, VapourSynth pipelines, MCP servers. | `uv tool install ruff` / pipx |
| **pywinauto/pywinauto** | Lets Claude Code drive GUI-only station apps (legacy broadcast tools, encoder frontends) programmatically — better agent lane than AHK. | `pip install pywinauto` |
| **Vinzent03/obsidian-git** | Vault under git = diff/rollback safety before letting agents edit the memory system; doubles as backup. | Obsidian community plugin |
| **gramps-project/gramps** | Open-source data backbone for genealogy; portable GEDCOM. Desktop editor half of a future Gramps Web pairing. | Windows installer |
| **tesseract-ocr/tesseract** | Quick-CLI OCR for census records, obits, archival station docs; pairs with a Claude skill that structures output. | `winget install UB-Mannheim.TesseractOCR` |
| **LAB02-Research/HASS.Agent** | Windows PC sensors/commands into Home Assistant (GPU load, wake-for-encode). Check the maintained fork/v2 line first. | installer (verify fork) |
| **caronc/apprise** | Universal "notify me when done" primitive for Claude Code hooks and overnight loops. | `pip install apprise` |

---

## 2. NEXT WAVE
*Queue after the top picks bed in; each is one trial session away from promotion.*

- **Restoration experiments (benchmark vs current pipeline, one at a time):** IceClear/SeedVR2 (one-step diffusion restoration; VRAM-hungry, use ComfyUI wrapper), taco-group/SparkVSR, jhogsett/EMA-VFI-WebUI (frame interpolation — the gap VapourSynth handles worst), dtaddis/ai-remaster-pipeline (outpaint/colorize).
- **McCloudS/subgen** — GPU Whisper auto-subtitles for Plex; NAS-side Bazarr webhooks point at the PC over Tailscale.
- **Huanshere/VideoLingo** — the winning dubbing/subtitle pipeline (see dedupe).
- **microsoft/VibeVoice** — long-form multi-speaker scratch VO; pin a known-good release.
- **jamiepine/voicebox** — GUI voice studio if the CLI TTS pair feels clunky.
- **heygen-com/hyperframes vs remotion-dev/remotion** — agent-driven HTML-to-video; trial hyperframes free, adopt Remotion only if station use justifies the company license.
- **nodecg/nodecg** — HTML5 broadcast-graphics playground for the motion-design lane.
- **Session management:** MatchaOnMuffins/orchestrator (live sessions) + doctly/switchboard (history search); agent-of-empires if mobile check-in via Tailscale matters more.
- **Memory bake-off:** supermemoryai/supermemory vs vectorize-io/hindsight — pick one, only after the OpenViking evaluation settles.
- **coleam00/Archon** — knowledge-backbone harness; Docker Desktop only.
- **Token-optimization trials:** bilalimamoglu/sift vs juyterman1000/entroly head-to-head; headroomlabs-ai/headroom for custom SDK pipelines; day50-dev/limit-model-spending if API-billed loops grow.
- **PaddlePaddle/PaddleOCR** — GPU batch OCR (genealogy, station archives) exposed as a local agent tool; tesseract stays the quick lane.
- **D4Vinci/Scrapling + microsoft/playwright** — scraping/monitoring stack for news dashboards; CloakBrowser held in reserve for bot-walled sites.
- **HaveAGitGat/Tdarr** — server on NAS, GPU transcode node on the PC (never transcode on the J4125).
- **Misc QoL:** cc-switch, spool (keep station work out — public by default), Folo or worldmonitor for the news wall, EverythingQuickSearch, llmfit, YishenTu/claudian (after obsidian-git), unslothai/unsloth (LoRA-on-promo-corpus learning project), gemini-cli/codex as second-opinion subagents.

---

## 3. DEDUPE DECISIONS

| Cluster | Keep | Drop / Park | Rationale |
|---|---|---|---|
| Scratch-VO TTS | Qwen3-TTS (GPU quality) + pocket-tts (CPU instant) | MiraTTS, OmniVoice-Studio, coqui-ai/TTS (archived) | Two lanes cover quality and convenience; the rest are redundant or dead. voicebox = optional GUI layer. |
| Subtitle/dubbing pipelines | VideoLingo | pyvideotrans, KrillinAI, SoniTranslate | Best-regarded of four starred; standardize. subgen is a *different job* (Plex auto-subs) — keep both. |
| Agentic video editors | FableCut (primary), video-use (middle bet) | agentic-video-editor (watch), OpenCut-app/OpenCut, rescript | FableCut's MCP/JSON-patch design fits his agent stack; SysAdminDoc/OpenCut is an unverified fork — vet before it touches a work machine. |
| AE automation | nexrender (+ py-aep at file layer) | jhd3197/after-effects-automation | Battle-tested vs immature; evaluate the latter only if nexrender's job model fails a workflow. |
| Image-gen UI | ComfyUI | AUTOMATIC1111 | A1111 stagnant; Comfy's JSON workflows are Claude-authorable. Boogu-Image loads *into* ComfyUI if VRAM allows (~12-16GB FP8). |
| Agent memory backends | OpenViking (evaluate vs _STATE/Obsidian first) | Observal; neo4j create-context-graph (weekend toy) | One serious evaluation, then a supermemory-vs-hindsight bake-off only if OpenViking loses. |
| Multi-agent harness | gastown | omnigent, agenticSeek, UI-TARS | One opinionated framework trial at a time; he's Claude-centric. |
| Tool-output compressors | Trial sift vs entroly, keep one; rtk for command output | pxpipe (documented lossy confabulation hazard), Context-Gateway (young) | Layered: rtk = commands, winner-of-two = general, headroom = SDK pipelines. |
| Session managers | orchestrator + switchboard (complementary: live vs history) | crystal/vibetunnel-alikes | agent-of-empires substitutes for orchestrator only if mobile access wins. |
| Browser automation | playwright (canonical) + Scrapling (scraping lib) | nanobrowser, browser-harness, Automa; Skyvern/CloakBrowser per-project only | Claude Code + MCP browsers already cover the agent lane. |
| OCR | tesseract (quick) + PaddleOCR (GPU batch) | baidu/Unlimited-OCR (unvetted English/handwriting) | Two proven tiers beat one unknown. |
| Downloaders/GUIs | yt-dlp (already core) | media-downloader GUI, TikTokDownloader (ad hoc only), frame (ffmpeg GUI) | He's CLI-fluent; GUIs add nothing. |
| Site archiving | wget --mirror / HTTrack | Website-downloader, gpt-crawler | Established tools cover it. |
| Photogrammetry/3D | colmap (if experiments start) | Meshroom (until a project demands it), TripoSplat (toy) | No current project; colmap is the prerequisite standard. |
| PKM apps | Obsidian (+obsidian-git, claudian) | reor (slowed dev), stenoai (macOS-first?) | Bolt features onto the vault, don't switch apps. |
| Ethically/legally parked | — | Deep-Live-Cam, LivePortrait (station use), voice cloning of talent, ace-step music on-air | Deepfake/clone tooling has no lane at a news station; hobby-only at most. |

---

## 4. GPU-HEAVY: WHY THE PC (not NAS, not cloud)

The DS423+ (J4125, no GPU, ~6GB RAM) and paid cloud both lose to the RTX desktop for:

1. **The entire VapourSynth restoration chain** — vs_deepdeinterlace, temporalfix, SeedVR2, SparkVSR, EMA-VFI, KAIR-family upscalers. These are the definitional GPU workloads; CPU Whisper-class inference on the J4125 is hours-per-file territory, and cloud GPU rental for a recurring hobby is exactly the always-on spend he avoids.
2. **ComfyUI + image/video gen** (Boogu-Image, LTX-Desktop) — VRAM-resident diffusion; zero marginal cost locally vs per-image cloud billing.
3. **subgen** — GPU Whisper serving the whole Plex library; NAS webhooks call the PC over Tailscale. Canonical split: NAS orchestrates, PC computes.
4. **Tdarr transcode node** — NVENC AV1 encodes for the library; server/UI on the NAS, GPU worker on the PC.
5. **CLIP + edit-mind footage indexing** — embedding generation is GPU-bound; the resulting ChromaDB index is small and query-light.
6. **Scratch-VO TTS** (Qwen3-TTS, VibeVoice) and **AudioSR** — real-time-or-better only on the GPU.
7. **unsloth fine-tuning / LlamaFactory / local LLMs (Ollama, LocalAI, Pythia)** — consumer-GPU-or-nothing; explicitly never the NAS.
8. **PaddleOCR batch jobs and photogrammetry (colmap/Meshroom)** — bursty CUDA batch work, ideal for a machine that's on when he's working anyway.

Standing rule this list encodes: **NAS = always-on orchestration, storage, webhooks; PC = all compute that touches CUDA; cloud = free tiers only (spool's Workers hub, optional worldmonitor on Vercel).**

---

# Part 3 — Cloud Services

Guiding rule: cloud is for things that are (a) public/static, (b) too heavy for the J4125, or (c) hosted-free-tier services he consumes rather than runs. Everything else stays on the NAS behind Tailscale or on the PC.

### 1. TOP PICKS — put these in the cloud

| What | Where | Why |
|---|---|---|
| **github-stars-viewer** (this app) | **GitHub Pages** | Static, already ideal. Zero cost, zero ops. Ship it. |
| **langfuse/langfuse** | **Langfuse Cloud free tier** | His biggest gap as he builds SDK agents/MCP servers is tracing + evals. v3 self-host needs ClickHouse + Redis + S3 — flatly not NAS-fit. Consume the hosted tier. |
| **firecrawl/firecrawl** | **Hosted free tier via MCP** | Reliable scraping for research agents and news loops without maintaining Playwright infra. Self-host (Redis + headless browsers) would flatten the Celeron. |
| **paperboytm/spool** (hub) | **Cloudflare Workers free tier** | Session archive with native Claude Code resume — plugs into his resumption-packet habit. The hub is Workers-native, not a container. Caveat: shared sessions are public by default — keep WFSB work out. |
| **lowlighter/metrics** | **GitHub Actions** | Ten-minute vanity dashboard for his increasingly public profile. Zero cost, zero maintenance. |

### 2. COULD be cloud, but better on the NAS behind Tailscale

Be explicit — these have cloud/hosted options, and he should decline them:

- **msgvault** — a lifetime of Gmail with FTS search does not belong on someone else's computer. Go + SQLite daemon is exactly what the DS423+ is for; query the MCP from desktop Claude Code over Tailscale.
- **apprise / apprise-api** — notification relay for hooks and ralph loops. Pipedream/Zapier could do this in the cloud; a tiny NAS container does it free with no vendor.
- **StevenBlack/hosts** — the cloud version of ad-blocking is NextDNS ($). AdGuard Home on the NAS consuming these lists is the better deployment, plus PC hosts file.
- **u14app/deep-research** — one-click Vercel deploy is tempting, but it's light enough for the NAS if he ever wants it, and Claude's built-in research covers most of it. Don't deploy just because it's easy.
- **PipedreamHQ/pipedream** — cloud glue for when PC/NAS are asleep, but the NAS *is never asleep*. n8n on the NAS + Claude Routines already cover this. Skip unless a specific always-on webhook need appears.
- **SoulSync / Tdarr / yt-dlp cron jobs** — never cloud candidates; listed only to confirm: NAS (orchestration) + PC GPU (heavy lifting).

### 3. NEXT WAVE / experiments (deploy only when a trigger fires)

- **quartz → GitHub Pages/Cloudflare Pages** — the moment he wants a public digital garden from the Obsidian vault. Not before.
- **worldmonitor → Vercel free tier** — Tauri desktop build on the PC first; add the Vercel deploy only if he wants the news wall reachable from phone/work.
- **supabase (hosted)** — parked as *the* answer if the budget tracker or fitness log ever needs real auth + Postgres. Nothing to do today.
- **googleworkspace/cli** — not cloud infra, but the highest-priority item in the batch: install on the PC, load its Agent Skills into desktop Claude Code for Drive/_STATE ops.
- **DigitalPlat FreeDomain (dpdns.org)** — grab a free subdomain only if something needs a public endpoint; Tailscale covers private access.
- **pi-worker (CF Workers)** — pure curiosity about serverless coding agents; weekend experiment tier.
- **Hosted-only, use-if-ever**: penpot.app (do NOT self-host), dub.co free tier (station analytics likely go through Gray anyway), zotero-arxiv-daily (gated on actually keeping a Zotero library), yumcut (brand control makes it a poor fit for station social).

**Bottom line:** only ~5 things genuinely belong in the cloud, and four of them are free hosted tiers he consumes, not deploys. The one real deployment is github-stars-viewer on GitHub Pages. The rest of the stack is NAS + PC, as it should be.

---

# Part 4 — Curated Install Plan: Starred Skills/Plugins for Desktop Claude Code

Guiding rule applied throughout: every installed skill costs trigger-space and context. One winner per category; bake-offs go to EVALUATE LATER; anything his existing ~60-skill arsenal already covers goes to SKIP with the covering skill named.

---

## 1. INSTALL NOW (21 items)

### Broadcast / Promo / Motion (his day job — highest leverage per install)

| # | Repo | What it adds | Install | Overlap notes |
|---|------|-------------|---------|---------------|
| 1 | **LottieFiles/motion-design-skill** | Motion-design principles (timing, easing, choreography, Disney principles) encoded for agents — from the most credible source in the category | git clone into `~/.claude/skills/motion-design` | Overlaps `broadcast-motion-design`, but that skill is about broadcast *delivery and engines*; this encodes *animation craft* Claude applies while generating. Complementary, not duplicate. Beats both iart-ai repos (see SKIP). |
| 2 | **bradautomates/claude-video** | Claude "watches" video via frame extraction + transcription — screen footage, log SOTs, review promo cuts | git clone per README | The missing sense for `ffmpeg-media-processing`. Pick this over the more obscure `claude-real-video` (EVALUATE). |
| 3 | **robonuggets/hyperframes-helper** | HTML-to-MP4 motion-graphics pipeline (GSAP + ffmpeg + faster-whisper, silence-cut/retake workflow) for social/promo video | git clone into `~/.claude/skills/hyperframes-helper`; needs Node 18+ and ffmpeg (already has both) | Verify HeyGen Hyperframes renderer licensing before relying on it for station work. |
| 4 | **heretorecord/ograf-graphics-skill** | Broadcast graphics to the EBU OGraf v1 open spec, with validators and vendored schemas | git clone into `~/.claude/skills/ograf-graphics` | WFSB runs Chyron/GrayONE, not OGraf renderers — this is a forward bet on open HTML broadcast graphics. Tiny repo (4 stars) but well-structured; pairs with `broadcast-motion-design`. Low cost, on-thesis. |
| 5 | **jamditis/claude-skills-journalism** | Verification, FOIA, data-journalism skills | git clone; **cherry-pick the verification and data-journalism skills only** — skip academic-writing | He sits inside a CBS newsroom; nothing in his stack covers source verification. |
| 6 | **coreyhaines31/marketingskills** | CRO/copywriting/SEO/growth/analytics skill pack | git clone; **cherry-pick growth + analytics + copywriting modules**; skip SEO/CRO bulk | Complements (doesn't duplicate) `broadcast-copywriting`/`ewn-*` — those are on-air voice; this is digital/social growth mechanics. |
| 7 | **mvanhorn/last30days-skill** | "What is the audience talking about right now" — 30-day research across Reddit/X/YouTube/HN | git clone into `~/.claude/skills/last30days` | Purpose-built for promo trend research and his news-monitoring habit. |
| 8 | **mshumer/unslop** | Samples a model per-domain, detects its repetitive defaults, emits a reusable anti-slop `skill.md` | pip/CLI on the PC; run against promo-copy and social-copy domains, feed output into skill library | Output is literally a skill.md — plugs into `broadcast-copywriting`/brian-voice. Generator, not a resident skill, so near-zero trigger cost. |

### Home / Personal / PKM

| # | Repo | What it adds | Install | Overlap notes |
|---|------|-------------|---------|---------------|
| 9 | **kepano/obsidian-skills** | Official skills (Obsidian's CEO) for the Obsidian CLI, Markdown, Bases, JSON Canvas | git clone into `~/.claude/skills/obsidian` | Most direct upgrade to his Obsidian-based memory architecture. Pair with obsidian-git for safety. |
| 10 | **komal-SkyNET/claude-skill-homeassistant** | HA automations, entity debugging, YAML wrangling as conversational work | git clone into `~/.claude/skills/homeassistant`; point at HA over Tailscale | No existing coverage. Quick win. |
| 11 | **homeassistant-ai/ha-mcp** | MCP server: Claude inspects and drives Home Assistant directly | `claude mcp add` (MCP config), HA over Tailscale | Pairs with #10 — skill supplies the know-how, MCP supplies the hands. |
| 12 | **googleworkspace/cli** | Official Workspace CLI: structured read/write to Drive/Gmail/Calendar/Sheets + 100+ bundled Agent Skills | npm install on the PC + copy the bundled skills you actually use | His `_STATE` docs live in Drive — this upgrades `memory-ops` directly. Pre-1.0; pin versions. |

### Agent Harness / Orchestration / Memory (one winner per category; bake-offs deferred)

| # | Repo | What it adds | Install | Overlap notes |
|---|------|-------------|---------|---------------|
| 13 | **anthropics/claude-plugins-official** | Anthropic's curated plugin directory | `/plugin marketplace add anthropics/claude-plugins-official`; browse, install selectively | Zero-risk, canonical upgrade path for his stack. Treat `anthropics/skills` the same way — he already runs docx/pptx/xlsx/pdf from it; diff for new additions quarterly rather than reinstalling. |
| 14 | **obra/superpowers** | The community-canonical skills framework (brainstorming, planning, TDD, subagent-driven dev) | `/plugin marketplace add obra/superpowers` | Real overlap with `skill-writer`/`tdd-workflow`/`scope-lock` — earns the slot anyway because his skill-authoring practice should be conversant with the de-facto standard; adopt the methodology skills selectively, disable duplicates. |
| 15 | **revfactory/harness** | Meta-skill: domain description in, generated agent team + their skills out, six orchestration patterns (8.6k stars) | `/plugin marketplace add revfactory/harness`; requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Automates what he hand-builds with `skill-composer`/`skill-creator`. Different niche from ralph loops (team *generation*, not loop execution). |
| 16 | **louislva/claude-peers-mcp** | Ad-hoc messaging between concurrent Claude Code sessions | MCP config; trivial install | He currently hacks this with files and triggers. Rare direct-advance item. |
| 17 | **thedotmack/claude-mem** | Compresses session transcripts into persistent searchable cross-session memory via hooks | `/plugin install` per README | **The one memory system to install now** — five-minute experiment against his `_STATE`/`session-start-hook` architecture. MemPalace, OpenViking, mem0, snarc all deferred to the bake-off (below) — running multiple memory hooks simultaneously is how you corrupt a working setup. |

### Dev Tooling / Quality

| # | Repo | What it adds | Install | Overlap notes |
|---|------|-------------|---------|---------------|
| 18 | **ChromeDevTools/chrome-devtools-mcp** | Official Google MCP driving a real Chrome instance | `claude mcp add` (npx) | Killer specific tie: CS2 Coui UI mods debug at localhost:9444 (`cs2-ui-modding`), plus agent-driven browser testing of his dashboards/stars viewer. |
| 19 | **8ddieHu0314/Skill-Lab** | Skill linter: 0-100 quality scoring, prompt-injection scanning, auto trigger tests (37 checks) | `pip install`, Python 3.10+; wire into `skill-creator` workflow | Directly on the critical path of this very curation exercise — vet everything else on this list with it. |
| 20 | **yetone/kill-ai-slop** | Field guide + skill that strips AI design *and copy* tics | git clone into `~/.claude/skills/kill-ai-slop` | **The one anti-slop pick** — the copy half matters most for a promo writer whose output must never read as AI. Beats hallmark, stop-slop, humanizer-stack, taste-skill, WRITING.md (all SKIP). |
| 21 | **google-labs-code/design.md** | DESIGN.md format: persistent structured visual-identity spec for agents | Adopt the convention (clone as reference); write a DESIGN.md for WFSB brand + one for personal projects | Complements `theme-factory`/`design-system-patterns` as the *handoff format*, not another design skill. The companion `bergside/design-md-chrome` extension only matters if the format sticks (EVALUATE). |

---

## 2. EVALUATE LATER (grouped bake-offs — do these deliberately, one weekend each)

**Memory bake-off** (after 2 weeks with claude-mem): **MemPalace/mempalace** (best-benchmarked, wings/rooms retrieval, pre-compaction hooks), **volcengine/OpenViking** (his memory architecture productized — memory+knowledge+skills as tiered virtual FS, MCP native), **mem0ai/mem0** (OpenMemory MCP, the OSS benchmark), **dp-web4/snarc** (salience-gated memory, dream-cycle consolidation — check hook collisions with `session-start-hook` first), **DeusData/codebase-memory-mcp** (code-graph memory — different niche, could coexist), **rohitg00/agentmemory**, supermemory vs hindsight (pick at most one from the whole group; the rest are reading material for `memory-ops`).

**Harness bake-off**: **gastownhall/gastown** (Yegge's Mayor/polecats — the flagship, but needs WSL2 + Go + tmux; trial on one repo before any migration), **Yeachan-Heo/oh-my-claudecode** (productized ralph loops — compare its ralph mode head-to-head against `ralph-wiggum` and keep the better exit heuristics), **affaan-m/ECC** (cherry-pick agents/hook patterns only; never wholesale), ruvnet/ruflo (hype-dense; sandbox trial only), coleam00/Archon (Docker Desktop knowledge backbone).

**Token/context tooling** (pick ONE compressor): rtk-ai/rtk vs bilalimamoglu/sift vs juyterman1000/entroly vs headroomlabs/headroom — measure on one long ralph loop before/after. teamchong/pxpipe separately: trial only on low-stakes sessions (documented hex-string confabulation hazard; on Max subscription it buys context headroom, not money).

**Spec workflow** (trial on one real build, keep at most one): github/spec-kit vs Fission-AI/OpenSpec vs gsd-build/get-shit-done — all overlap `scope-lock`/`output-specification-first`/`build-wizard`; his homegrown discipline may already be tighter.

**Session management**: doctly/switchboard (session history search — feeds `resumption-packet`), MatchaOnMuffins/orchestrator (live multiplexing), agent-of-empires (mobile monitoring of ralph loops over Tailscale — real gap), paperboytm/spool (sessions public by default — keep station work out), dcramer/dex (weigh against Todoist MCP).

**Broadcast/creative second wave**: **VideoZero/skills** (Motion Canvas programmatic video — skills.sh format needs adaptation; install if hyperframes-helper disappoints or a structured-explainer need lands), HUANGCHIHHUNGLeo/claude-real-video (only if claude-video falls short), **realkimbarrett/advertising-skills** (vet against `ewn-*` — likely partial overlap), Panniantong/Agent-Reach (social-platform eyes; needs his logins; overlaps last30days).

**Design second wave**: ibelick/ui-skills, pbakaus/impeccable, kwakseongjae/oh-my-design — only if artifacts still read generic after kill-ai-slop + design.md.

**Skill-factory feeders**: yusufkaraaslan/Skill_Seekers (docs-to-skill for CS2/VapourSynth/Synology docs), assafelovic/skyll, Archive228/loopkit + addyosmani/agent-skills + mattpocock/skills (cherry-pick sources — audit with Skill-Lab first), amElnagdy/guard-skills (quality gates for ralph loops), anthropics/knowledge-work-plugins (check content/marketing plugins against ewn-* overlap), promptfoo (regression tests for skill prompts — the real eval gap; graduate to install once he ships his next skill batch).

**PKM/personal**: danielmiessler/Telos + LifeOS (mine the file structures into `_STATE` conventions — document formats, not installs), ohad6k/emulo (mine session logs into a you.md — feeds `procedural-memory-distillation`; run once, judge output), mattprusak/autoresearch-genealogy (adapt into a proper skill when genealogy season returns), kenn-io/msgvault (NAS daemon, alpha — genealogy/Gmail archive), AgriciDaniel/claude-obsidian (test on a vault *copy* only), koala73/worldmonitor (Tauri desktop news wall — fun, not urgent).

**Infra/misc**: openclaw/openclaw (NAS always-on gateway — separate NAS project, not a desktop install; lock down pairing), RightNow-AI/openfang (NAS agent daemon; overlaps Claude Code Routines), caronc/apprise (universal notify primitive for hook completion — cheap, install when a loop next annoys him), firecrawl hosted MCP + langfuse Cloud (when SDK-agent work scales), fabio-rovai/open-ontologies (real reasoning engine for `ontological-harness` — sanity-check build quality), openai/codex-plugin-cc (only if he starts paying OpenAI), UditAkhourii/adhd + uditgoenka/autoresearch (compare against judge-panel/ralph patterns), Tdarr + SoulSync (media-stack projects, not Claude Code installs), cc-switch (only if he starts multi-config experiments).

---

## 3. SKIP — redundant with the existing arsenal (covering skill named)

| Repo(s) | Covered by |
|---|---|
| Nutlope/hallmark, hardikpandya/stop-slop, NulightJens/humanizer-stack, Anbeeld/WRITING.md, Leonxlnx/taste-skill | kill-ai-slop (installing) + brian-voice + `broadcast-copywriting` + `audience-of-one` |
| iart-ai/motion-design-skills, iart-ai/motion-skills | LottieFiles/motion-design-skill (installing) + `broadcast-motion-design` |
| fivetaku/fablize, duolahypercho/fusion-fable, mrtooher/fable-mode, TheColliny/FableClaudeMDForOpus, Sahir619/fable-method, Miguok/fable-harness | He runs the actual frontier Claude models directly; `ralph-wiggum` + `self-check-loop` + `grill-me` cover the verification behavior |
| mattnowdev/thinking-partner, human-avatar/skills-for-humanity, 0xNyk/council-of-high-intelligence, sjsyrek/design-council, karpathy/llm-council, garrytan/gstack, msitarzewski/agency-agents, alchaincyf/steve-jobs-skill | `mental-models-analysis`, judge-panel, `audience-of-one`, `decision-register` |
| blader/taskmaster, snarktank/ralph, frankbria/ralph-claude-code, Ibrahim-3d/orchestrator-supaconductor | `ralph-wiggum` + `ralph-loop-orchestration` (diff frankbria's exit heuristics as reading only) |
| wonderwhy-er/DesktopCommanderMCP, aaif-goose/goose, openinterpreter, OpenHands, AutoGPT, Fosowl/agenticSeek, CoderLuii/HolyClaude, SterlingChin/marvin-template | Claude Code itself |
| nextlevelbuilder/ui-ux-pro-max-skill | `uiux-augmentation` + `design-system-patterns` + `theme-factory` |
| jgerton/brand-toolkit | `ewn-brand-conventions` |
| LeoTheAIDev/Altiverse, KeaBase/kea-research | `ewn-insurgent-playbook` audience scoring + judge-panel cross-validation |
| BradGroux/veritas-kanban, MeisnerDan/mission-control | dex (if any tracker at all) + Todoist MCP |
| DietrichGebert/ponytail, drona23/claude-token-efficient | `delta-output` + `scope-lock` + `strategic-compact` |
| modiqo/skillspec, sickn33/agentic-awesome-skills, refly-ai/refly | `skill-creator`/`skill-writer`/`skill-composer`/`skill-lookup` |
| OmniRoute, Alishahryar1/free-claude-code, KorroAi/onklaud-5 | ToS-gray routing; he's on a paid Anthropic plan |
| Flowise, dify, sim, lobehub, gpt-researcher, phantom, sentrux, brainapi2, ContextKeep, Observal, Skyvern/nanobrowser (mostly), boring-computers, zeroboot, cua, multica, adamlyttleapps onboarding, Figma MCP, pathwaycom, open-and-async/mcp | Wrong platform, wrong problem, security nonstarter, or covered by Claude Code + existing MCPs |
| github/github-mcp-server, upstash/context7, anthropics/claude-code, yt-dlp, multica-ai/andrej-karpathy-skills | Already installed/connected — bookkeeping stars, no action (check karpathy-skills for upstream drift) |

**Reference shelf, not installs** (read, steal patterns, never deploy): humanlayer/12-factor-agents (actually read this one), langchain deepagents + PocketFlow + Mini-Agent (harness source reading), system_prompts_leaks + x1xhlol (prompt architecture study), Fabric /patterns (raid for skill-writer), hippo-memory + Memoria + TencentDB-Agent-Memory + LeoYeAI auto-dream (memory mechanics reading for `memory-ops`), OmniParser (the AE-GUI-automation long game), all awesome-lists (periodic mining sweeps), NemoClaw (sandbox hardening ideas for overnight loops).

---

## 4. Special Cases: Broadcast-Relevant Deep Cut

The broadcast cluster is where this batch over-delivers, and it deserves its own logic:

- **Motion**: LottieFiles is the credibility anchor — install first, alone. The iart-ai pair is the same idea with less pedigree; three overlapping motion-principles skills would fight each other in trigger-space. hyperframes-helper and VideoZero attack *rendered output* (MP4s) rather than principles — hyperframes wins round one because its silence-cut/talking-head workflow maps to social promo deliverables he ships weekly; VideoZero graduates if a structured-explainer project appears.
- **ograf-graphics-skill** is the one "install despite no immediate renderer" pick: HTML-based open-spec broadcast graphics is exactly where CasparCG/Singular-style workflows are heading, it's tiny, and it composes with `broadcast-motion-design` and `cs2-ui-modding`'s HTML/Chrome tooling. If GrayONE ever grows OGraf/HTML ingest, he's a year ahead.
- **Journalism**: cherry-pick verification + data-journalism from jamditis — the only skills in his entire stack that cover sourcing rigor, and promo increasingly touches news content.
- **Advertising/marketing**: marketingskills (growth/analytics/copy modules) installs now because it covers *digital growth mechanics* his ewn-* stack deliberately doesn't; advertising-skills waits until vetted against `ewn-promo-workflow` — his custom skills are likely better than a generic ad pack, and Skill-Lab (#19) is the right vetting tool.
- **The video-understanding pair** (claude-video now, claude-real-video later) plus `ffmpeg-media-processing` finally closes the loop: Claude can pull frames, watch cuts, log SOTs, and hand mark-in/out back to ffmpeg. That is a genuine new capability class for his day job, not another skill variant.

**Net effect**: 21 installs (8 broadcast/creative, 4 home/PKM, 5 harness/memory, 4 tooling/quality), every bake-off deferred with a decision procedure, and roughly 100 stars explicitly retired so they stop generating "should I install this?" ambient load.

---

*Install automation for Part 4 lives in [deployment/skills/](deployment/skills/). The full 763-repo classification behind every list above is in [deployment/ANALYSIS.md](deployment/ANALYSIS.md).*

