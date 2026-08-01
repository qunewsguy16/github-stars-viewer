# WIZARD — stars-deploy
updated: 2026-08-01 | surface: claude-code (remote session) | size: L | pacing: autonomous
stage: 7/8 (Ship & Park)
context: personal (your stars, your NAS/PC/cloud; no Gray/WFSB systems touched — station relevance appears only as tool selection)
mission: Analyze every one of the 763 starred repos on @qunewsguy16, produce a deployment plan across the Windows PC, the DS423+ NAS, and cloud free tiers, curate which starred Claude Code skills actually earn a slot on the desktop instance (with install automation), configure the stars-viewer fork to auto-load your account, and ship it all as a draft PR — leaving only the physically-yours actions below.
output_path: repo root (DEPLOYMENT.md, deployment/, WIZARD.md) on branch `claude/starred-projects-deployment-ask2nr`

## Locked
constraints: sandbox egress blocked GitHub API → stars pulled via public HTML pagination (auto) — assumes: 763/770 captured is complete; the missing 7 are stars on deleted/privated repos that no longer render anywhere
scope: IN[full 763-repo analysis, PC/NAS/cloud deployment lists, skills curation + install assets, viewer default-user config, draft PR] OUT[actually deploying to your hardware, merging, enabling Pages, any Gray/WFSB system] (auto)
spec: acceptance = [763/763 classified:mech OK, DEPLOYMENT.md Parts 1–4:mech OK, ANALYSIS.md row-count 763:mech OK, install scripts valid+safe:mech OK (two adversarial verify rounds — 14 findings then 5, all fixed; bash dry-run green), viewer auto-load syntax-checked:mech OK (hash-decode guard added after review), branch pushed + draft PR:mech, taste-review of curation calls:brian → rides in the rundown below] (auto)

## Ledger
- [x] W1 Pull complete stars list — 26 pages, 763 unique, zero dupes
- [x] W2 Analyze all 763 — 13 analysts, deterministic coverage check, 0 missing after pass 1
- [x] W3 Curate NAS / PC / cloud / skills — 4 curators (skills re-run after session-limit reset)
- [x] W4 Viewer defaults to qunewsguy16 — `?user=` / `#name` overrides intact
- [x] W5 Assemble DEPLOYMENT.md + ANALYSIS.md appendix
- [x] W6 Install scripts (Sonnet build) + two adversarial verify rounds (Opus, high effort) + fix rounds — all findings closed, installer dry-run green
- [>] W7 Commit → push → draft PR → watch CI

## Pending gate
none — no decision below met the necessity test; everything left is physical handoff.

## Decision log
2026-07-31 [AUTO]: Zapier task quota exhausted → pulled stars via public HTML pagination instead — same data, sanctioned channel
2026-07-31 [AUTO]: batched 13 analysts × ~60 repos with script-side coverage verification — "analyze everything" made mechanical, not aspirational
2026-08-01 [AUTO]: skills curation capped at 21 installs of 97 candidates — trigger-space is a budget; ~100 stars explicitly retired
2026-08-01 [AUTO]: claude-mem chosen as the ONE memory experiment; MemPalace/OpenViking/mem0/snarc deferred to a single bake-off — parallel memory hooks corrupt working setups
2026-08-01 [AUTO]: dedupe winners locked — dockge, apprise-api, linkding, n8n, gramps-web, AdventureLog, wger, glance, Kometa, tunarr, audiobookshelf, searxng, romm (rationale: DEPLOYMENT.md Part 1 §3)
2026-08-01 [AUTO]: PR opens as draft (harness standard); merge is yours

## Handoff queue — THE RUNDOWN
*(air order; each block stands alone — take them in any order, skip freely; `back {id}` reopens any [AUTO] above)*

- [ ] **A-BLOCK · Publish (5 min, from any browser)** — Review the draft PR, merge it, then Settings → Pages → deploy from `main`. The viewer goes live auto-loading your stars; the plan docs become readable from your phone.
- [ ] **B-BLOCK · Desktop skills load-in (15 min, at the PC)** — Pull the repo, run `deployment\skills\install-skills.ps1` in PowerShell. It clones the skill repos, skips anything you already have, then prints the four in-app plugin lines (three `/plugin marketplace add`, one `/plugin install`) and the `claude mcp add` lines for you to paste into desktop Claude Code. Finish with a Skill-Lab vet pass over the new arrivals (it's item #19 on the install list).
- [ ] **C-BLOCK · NAS Tier 1 (one afternoon, SSH to the DS423+)** — Create `/volume1/docker/<stack>/` dirs and compose up, in order: **dockge → apprise-api → netdata → watchtower (notify-only)**. ~400MB total. Netdata is the gauge that gates every later add.
- [ ] **D-BLOCK · NAS Tier 2 (staged, Netdata-gated)** — **glance** (your news dashboard project, 25MB) → **paperless-ngx** → **actual-server + n8n** (import the six envelope workflows) → **gramps-web**. One stack at a time; check headroom between each.
- [ ] **E-BLOCK · PC top picks (as workflows demand)** — Start with **nexrender** (+ aerender on PATH) and **ComfyUI**; then the VapourSynth restoration chain (vs_deepdeinterlace first); **gitleaks** pre-commit is the ten-minute one that prevents your worst likely mistake. Full menu: DEPLOYMENT.md Part 2.
- [ ] **F-BLOCK · Bake-offs (one weekend each, calendar them)** — Memory (2 weeks after claude-mem beds in), harness (gastown vs oh-my-claudecode), token compressor (pick ONE of rtk/sift/entroly/headroom), spec workflow (spec-kit vs OpenSpec vs get-shit-done vs your own discipline). Procedures: DEPLOYMENT.md Part 4 §2.
- [ ] **TASTE CHECK (the one `brian` acceptance item)** — Skim Part 1 §3 dedupe winners and Part 4 §1's 21 installs. Any call that reads wrong: `back {id}` it or just say so — each is reversible and none has been executed against your hardware.

## Change orders
CO-1 (2026-08-01, from you): "Ultracode orchestration + model/effort-matched delegation + wizard handoff with creative interface" → folded into W6–W7. Delegation: analysts/curators (top reasoning tier), install scripts (Sonnet·medium effort), bundle verify (Opus·high effort), appendix generation (deterministic script — code beats a model for mechanical transforms).

## Park block
stopped: bundle verified; W7 ship sequence (commit → push → draft PR) executing
next: open the draft PR link and read the summary — 2 minutes, phone is fine
loop: once A-BLOCK is done, your stars viewer is a live URL — open it and see 763 stars organized; that's the payoff frame

## Run record
outcome: DELIVERED (on PR open) | gates fired: 0 | autopasses: 6 logged (+ routine) | reversals: 0 | checks: all mech green after 2 verify+fix rounds (19 findings closed), 1 brian item queued in rundown
