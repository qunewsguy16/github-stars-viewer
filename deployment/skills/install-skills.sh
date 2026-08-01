#!/usr/bin/env bash
#
# install-skills.sh
#
# Installs the "INSTALL NOW" skills/plugins/MCP servers curated in
# ../../DEPLOYMENT.md Part 4, section 1 (INSTALL NOW), for WSL / macOS / Linux use.
#
# Reads skills-manifest.txt from its own directory and, per entry:
#   clone-skill : shallow git-clones the repo into a temp dir, then copies any
#                 folder(s) containing SKILL.md (or the whole repo if none is
#                 found) into $HOME/.claude/skills/<target-name>. Never
#                 overwrites an existing skill directory - skips it with a
#                 warning instead.
#   pip / npm   : runs the recorded command only when it is a concrete
#                 pip/pip3/npm invocation; commands containing a <placeholder>
#                 or starting with anything else are printed as manual steps.
#   mcp         : prints the recorded "claude mcp add" command for manual review
#                 (these usually need a repo-specific arg filled in).
#   plugin /
#   manual      : cannot be scripted from outside Claude Code. Collected and
#                 printed as numbered instructions at the end.
#
# Idempotent and non-destructive: re-running this script never deletes or
# overwrites anything already installed. It only adds what is missing.
#
# No emoji.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
MANIFEST_PATH="${1:-$SCRIPT_DIR/skills-manifest.txt}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"

info()  { printf '[INFO]  %s\n' "$1"; }
warn()  { printf '[WARN]  %s\n' "$1" >&2; }
err()   { printf '[ERROR] %s\n' "$1" >&2; }
ok()    { printf '[OK]    %s\n' "$1"; }

if [[ ! -f "$MANIFEST_PATH" ]]; then
    err "Manifest not found: $MANIFEST_PATH"
    exit 1
fi

mkdir -p "$SKILLS_DIR"

GIT_AVAILABLE=1
if ! command -v git >/dev/null 2>&1; then
    warn "git was not found on PATH. clone-skill entries will be skipped."
    GIT_AVAILABLE=0
fi

installed=()
skipped=()
failed=()
manual_steps=()

# Trim leading/trailing whitespace from a string
trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

while IFS=$'\t' read -r method repo note <&3 || [[ -n "${method:-}" ]]; do
    # skip blank lines and comments
    [[ -z "${method:-}" ]] && continue
    method="$(trim "$method")"
    [[ "$method" =~ ^#.*$ ]] && continue
    [[ -z "$method" ]] && continue

    repo="$(trim "${repo:-}")"
    note="$(trim "${note:-}")"

    case "$method" in

        clone-skill)
            if [[ "$GIT_AVAILABLE" -eq 0 ]]; then
                warn "Skipping $repo (git unavailable)."
                failed+=("$repo (git unavailable)")
                continue
            fi

            target="${note%%::*}"
            target="$(trim "$target")"
            if [[ -z "$target" ]]; then
                target="${repo##*/}"
            fi

            dest_dir="$SKILLS_DIR/$target"

            if [[ -e "$dest_dir" ]]; then
                warn "Skipping $repo -> already installed at $dest_dir (not overwritten)."
                skipped+=("$repo -> $dest_dir")
                continue
            fi

            tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/skill-clone-XXXXXX")"
            clone_ok=1
            info "Cloning $repo (shallow) ..."
            if ! git clone --depth 1 "https://github.com/$repo.git" "$tmp_dir" </dev/null >/dev/null 2>&1; then
                err "git clone failed for $repo"
                failed+=("$repo (git clone failed)")
                rm -rf "$tmp_dir"
                continue
            fi

            # find directories containing SKILL.md
            mapfile -t skill_dirs < <(find "$tmp_dir" -type f -name 'SKILL.md' -exec dirname {} \; | sort -u)

            if [[ "${#skill_dirs[@]}" -gt 0 ]]; then
                if [[ "${#skill_dirs[@]}" -eq 1 ]]; then
                    info "Copying skill folder for $repo into $dest_dir ..."
                    cp -R "${skill_dirs[0]}" "$dest_dir"
                    ok "Installed $repo -> $dest_dir"
                    installed+=("$repo -> $dest_dir")
                else
                    mkdir -p "$dest_dir"
                    for sd in "${skill_dirs[@]}"; do
                        sub="$dest_dir/$(basename "$sd")"
                        if [[ -e "$sub" ]]; then
                            warn "  Sub-skill already exists, skipping: $sub"
                            continue
                        fi
                        cp -R "$sd" "$sub"
                    done
                    ok "Installed $repo (multiple skills) -> $dest_dir"
                    installed+=("$repo -> $dest_dir (multiple skill dirs, cherry-pick as needed)")
                fi
            else
                info "No SKILL.md found in $repo; copying whole repo into $dest_dir ..."
                cp -R "$tmp_dir" "$dest_dir"
                ok "Installed $repo -> $dest_dir (whole repo)"
                installed+=("$repo -> $dest_dir (whole repo, no SKILL.md detected)")
            fi

            if [[ "$note" == *"::"* ]]; then
                warn "  Note for $repo: $(trim "${note#*::}")"
            fi

            rm -rf "$tmp_dir"
            ;;

        pip|npm)
            cmd="${note%%::*}"
            cmd="$(trim "$cmd")"
            info "$method step for $repo: $cmd"

            if [[ "$cmd" == *"<"*">"* || "$cmd" == *"("* || "$cmd" == *")"* ]]; then
                warn "  Command contains a <placeholder> or prose - cannot run automatically."
                manual_steps+=("[$repo] ($method - fill in placeholder and run manually) $cmd")
            else
                read -r -a cmd_arr <<< "$cmd"
                exe="${cmd_arr[0]:-}"
                case "$exe" in
                    pip|pip3|npm)
                        info "Running: $cmd"
                        if "${cmd_arr[@]}"; then
                            ok "Ran $method install step for $repo"
                            installed+=("$repo ($method: $cmd)")
                        else
                            err "$method step failed for $repo"
                            failed+=("$repo ($method step failed)")
                        fi
                        ;;
                    *)
                        warn "  Command does not start with pip/pip3/npm - not running automatically."
                        manual_steps+=("[$repo] ($method - review and run manually) $cmd")
                        ;;
                esac
            fi
            ;;

        mcp)
            info "mcp step for $repo: $note"
            if [[ "$note" == *"<"*">"* ]]; then
                warn "This command likely needs a repo-specific command/URL filled in - review before running."
            fi
            manual_steps+=("[$repo] (mcp - review and run manually) $note")
            ;;

        plugin)
            manual_steps+=("[$repo] (in-app plugin step) $note")
            ;;

        manual)
            manual_steps+=("[$repo] (manual) $note")
            ;;

        *)
            warn "Unknown method '$method' for $repo - treating as manual."
            manual_steps+=("[$repo] (unknown method '$method') $note")
            ;;
    esac

done 3< "$MANIFEST_PATH"

echo ""
echo "==================== SUMMARY ===================="
echo "Installed : ${#installed[@]}"
for i in "${installed[@]:-}"; do
    [[ -n "$i" ]] && echo "  - $i"
done
echo "Skipped (already present) : ${#skipped[@]}"
for s in "${skipped[@]:-}"; do
    [[ -n "$s" ]] && echo "  - $s"
done
echo "Failed : ${#failed[@]}"
for f in "${failed[@]:-}"; do
    [[ -n "$f" ]] && echo "  - $f"
done
echo "==================================================="

if [[ "${#manual_steps[@]}" -gt 0 ]]; then
    echo ""
    echo "The following steps are NOT scriptable and must be run inside Claude Code (or by hand):"
    n=1
    for step in "${manual_steps[@]}"; do
        echo "  $n. $step"
        n=$((n + 1))
    done
fi

echo ""
info "Done. Re-run this script any time - it will skip anything already installed."
