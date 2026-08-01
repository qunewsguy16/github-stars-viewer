# WIZARD — stars-deploy
updated: 2026-08-01 | surface: claude-code (remote session) | size: L | pacing: autonomous
stage: 8/8 (Ship & Park) — DELIVERED; PR #1 merged 2026-08-01
context: personal (your stars, your NAS/PC/cloud; no Gray/WFSB systems touched — station relevance appears only as tool selection)
mission: Analyze every one of the 763 starred repos on @qunewsguy16, produce a deployment plan across the Windows PC, the DS423+ NAS, and cloud free tiers, curate which starred Claude Code skills actually earn a slot on the desktop instance (with install automation), configure the stars-viewer fork to auto-load your account, and ship it all as a PR — leaving only the physically-yours actions below.
output_path: repo root (DEPLOYMENT.md, deployment/, WIZARD.md), merged to main

## Locked
constraints: sandbox egress blocked GitHub API → stars pulled via public HTML pagination (auto) — assumes: 763/770 captured is complete; the missing 7 are stars on deleted/privated repos that no longer render anywhere
scope: IN[full 763-repo analysis, PC/NAS/cloud deployment lists, skills curation + install assets, viewer default-user config, PR] OUT[actually deploying to your hardware, enabling Pages, any Gray/WFSB system] (auto)
spec: acceptance = [763/763 classified:mech OK, DEPLOYMENT.md Parts 1–4:mech OK, ANALYSIS.md row-count 763:mech OK, install scripts valid+safe:mech OK (two adversarial verify rounds — 14 findings then 5, all fixed; bash dry-run green), viewer auto-load syntax-checked:mech OK (hash-decode guard added after review), branch pushed + PR:mech OK (merged), taste-review of curation calls:brian → in the handoff queue] (auto)

## Ledger
- [x] W1 Pull complete stars list — 26 pages, 763 unique, zero dupes
- [x] W2 Analyze all 763 — 13 analysts, deterministic coverage check, 0 missing after pass 1
- [x] W3 Curate NAS / PC / cloud / skills — 4 curators (skills re-run after session-limit reset)
- [x] W4 Viewer defaults to qunewsguy16 — `?user=` / `#name` overrides intact
- [x] W5 Assemble DEPLOYMENT.md + ANALYSIS.md appendix
- [x] W6 Install scripts (Sonnet build) + two adversarial verify rounds (Opus, high effort) + fix rounds — all findings closed, installer dry-run green
- [x] W7 Commit → push → draft PR #1 → marked ready and merged by Brian 2026-08-01

## Pending gate
none — everything left is physical handoff.

## Decision log
2026-07-31 [AUTO]: Zapier task quota exhausted → pulled stars via public HTML pagination instead — same data, sanctioned channel
2026-07-31 [AUTO]: batched 13 analysts × ~60 repos with script-side coverage verification — "analyze everything" made mechanical, not aspirational
2026-08-01 [AUTO]: skills curation capped at 21 installs of 97 candidates — trigger-space is a budget; ~100 stars explicitly retired
2026-08-01 [AUTO]: claude-mem chosen as the ONE memory experiment; MemPalace/OpenViking/mem0/snarc deferred to a single bake-off — parallel memory hooks corrupt working setups
2026-08-01 [AUTO]: dedupe winners locked — dockge, apprise-api, linkding, n8n, gramps-web, AdventureLog, wger, glance, Kometa, tunarr, audiobookshelf, searxng, romm (rationale: DEPLOYMENT.md Part 1 §3)
2026-08-01 [AUTO]: PR opened as draft (harness standard); Brian marked ready and merged
2026-08-01 [REVERSAL, Brian]: broadcast-rundown skin on the wizard surface reverted to the standard format — miscalibration logged (creative-interface latitude does not mean themed chrome); surface category tightened for this wizard's remainder

## Handoff queue
- [ ] Enable GitHub Pages: in a browser (not the GitHub app), open github.com/qunewsguy16/github-stars-viewer/settings/pages → Source: Deploy from a branch → Branch: main, / (root) → Save. Site: qunewsguy16.github.io/github-stars-viewer/
- [ ] At the PC: pull the repo, run `deployment\skills\install-skills.ps1` in PowerShell; then paste the printed in-app plugin lines (three `/plugin marketplace add`, one `/plugin install`) and `claude mcp add` lines into desktop Claude Code; vet the new arrivals with Skill-Lab (install item #19)
- [ ] On the NAS (SSH, one afternoon): create `/volume1/docker/<stack>/` dirs and compose up Tier 1 in order — dockge → apprise-api → netdata → watchtower (notify-only). ~400MB total; Netdata gates every later add
- [ ] NAS Tier 2, one stack at a time, Netdata-gated: glance → paperless-ngx → actual-server + n8n (import the six envelope workflows) → gramps-web
- [ ] PC installs as workflows demand: start with nexrender (+ aerender on PATH) and ComfyUI; then the VapourSynth restoration chain (vs_deepdeinterlace first); gitleaks pre-commit is the ten-minute one. Full menu: DEPLOYMENT.md Part 2
- [ ] Calendar the four bake-offs, one weekend each: memory (2 weeks after claude-mem beds in), harness (gastown vs oh-my-claudecode), token compressor (pick ONE of rtk/sift/entroly/headroom), spec workflow (spec-kit vs OpenSpec vs get-shit-done vs current discipline). Procedures: DEPLOYMENT.md Part 4 §2
- [ ] Taste review (the one `brian` acceptance item): skim Part 1 §3 dedupe winners and Part 4 §1's 21 installs; flag anything that reads wrong — every call is reversible and none has been executed against your hardware

## Change orders
CO-1 (2026-08-01, from Brian): ultracode orchestration + model/effort-matched delegation + wizard handoff → folded into W6–W7. Delegation: analysts/curators (top reasoning tier), install scripts (Sonnet·medium effort), bundle verify (Opus·high effort), appendix generation (deterministic script — code beats a model for mechanical transforms).
CO-2 (2026-08-01, from Brian): revert themed wizard surface to the standard format → this file rewrite; shipped as a follow-up PR after PR #1 merged.

## Park block
stopped: everything shipped and merged; only human-side deploys remain
next: open github.com/qunewsguy16/github-stars-viewer/settings/pages in a browser and enable Pages from main — under 2 minutes
loop: once Pages is live, the viewer auto-loads your 763 stars at qunewsguy16.github.io/github-stars-viewer/ — that's the payoff check

## Run record
outcome: DELIVERED (PR #1 merged) | gates fired: 0 | autopasses: 6 logged (+ routine) | reversals: 1 (surface format, post-delivery) | checks: all mech green after 2 verify+fix rounds (19 findings closed), 1 brian item queued in handoff
