# Skills install automation

Scripts to install the 21 "INSTALL NOW" skills/plugins/MCP servers from the
starred-repo curation (`../../DEPLOYMENT.md`, Part 4, section 1 - INSTALL NOW)
onto a desktop Claude Code instance.

## Files

- `skills-manifest.txt` - machine-readable list of what to install and how.
- `install-skills.ps1` - PowerShell installer (Windows PC, primary shell).
- `install-skills.sh` - bash installer (WSL / macOS, equivalent behavior).
- `README.md` - this file.

Both scripts read the same manifest, are idempotent, and never delete or
overwrite anything already present. Re-running is always safe: anything
already installed is skipped with a warning, not touched.

## Run order

1. **Run the script for your shell.**
   - Windows / PowerShell: `.\install-skills.ps1`
   - WSL / macOS / Linux: `./install-skills.sh`

   This handles everything that can be done from the command line:
   `clone-skill` entries (git clone + copy into `~/.claude/skills/<name>`),
   and `pip`/`npm` installs when the recorded command is a concrete,
   whitelisted `pip`/`pip3`/`npm` invocation. Entries whose command still
   contains a `<placeholder>` (or starts with something other than
   pip/pip3/npm) are not executed - they're printed as manual steps instead.
   It also prints (but does not run) the `mcp` commands since those usually
   need a repo-specific argument filled in first.

2. **Do the printed in-app steps inside Claude Code.** At the end of the run
   the script prints a numbered list of everything it could *not* do itself:
   - `plugin` entries - run `/plugin marketplace add owner/repo` (or
     `/plugin install owner/repo`) inside Claude Code.
   - `mcp` entries - review the printed `claude mcp add ...` command (fill in
     the repo-specific command/URL per its README) and run it.
   - `manual` entries - one-off items that need a human decision, e.g.
     adopting the DESIGN.md convention rather than installing a skill.

## Cherry-pick notes

Two manifest entries deliberately install only part of the source repo -
copy just the named skill folders, not the whole thing, into
`~/.claude/skills/`:

- **jamditis/claude-skills-journalism** - keep only the **verification** and
  **data-journalism** skills. Skip academic-writing; it's not relevant to
  the newsroom use case.
- **coreyhaines31/marketingskills** - keep only the **growth**,
  **analytics**, and **copywriting** modules. Skip the SEO/CRO bulk - it's
  not on-thesis and would just add trigger-space noise.

The scripts copy the whole repo (or every SKILL.md dir they find) for these
two, matching the manifest note; do the actual pruning by hand afterward -
delete the sub-skill folders you don't want to keep from
`~/.claude/skills/claude-skills-journalism/` and
`~/.claude/skills/marketingskills/`. The scripts never delete anything
automatically, by design.

## Full rationale

This manifest is a mechanical extraction of one section of a larger
curation exercise. For *why* each item was chosen, what was deferred to a
bake-off, and what was skipped as redundant, see
**`../../DEPLOYMENT.md`, Part 4**.
