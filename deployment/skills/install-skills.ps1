<#
.SYNOPSIS
    Installs the "INSTALL NOW" skills/plugins/MCP servers curated in
    ../../DEPLOYMENT.md Part 4, section 1 (INSTALL NOW) onto this desktop Claude
    Code instance.

.DESCRIPTION
    Reads skills-manifest.txt from its own directory and, per entry:
      - clone-skill : shallow git-clones the repo into a temp dir, then copies any
                      folder(s) containing SKILL.md (or the whole repo if none is found)
                      into $HOME/.claude/skills/<target-name>. Never overwrites an
                      existing skill directory - skips it with a warning instead.
      - pip / npm   : runs the recorded command only when it is a concrete
                      pip/pip3/npm invocation; commands containing a <placeholder>
                      or starting with anything else are printed as manual steps.
      - mcp         : prints the recorded "claude mcp add" command for manual review
                      (these usually need a repo-specific arg filled in).
      - plugin /
        manual      : cannot be scripted from outside Claude Code. Collected and
                      printed as numbered instructions at the end for the human to
                      run inside Claude Code (or by hand).

    Idempotent and non-destructive: re-running this script never deletes or
    overwrites anything already installed. It only adds what is missing.

.NOTES
    No emoji. Run from PowerShell (Windows), or pwsh (cross-platform) for WSL/macOS.
#>

[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot 'skills-manifest.txt'),
    [string]$SkillsDir = (Join-Path $HOME '.claude/skills')
)

$ErrorActionPreference = 'Stop'

function Write-Info    { param($msg) Write-Host "[INFO]  $msg" }
function Write-Warn2   { param($msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err2    { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Ok      { param($msg) Write-Host "[OK]    $msg" -ForegroundColor Green }

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    Write-Err2 "Manifest not found: $ManifestPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $SkillsDir)) {
    Write-Info "Creating skills directory: $SkillsDir"
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

$gitAvailable = [bool](Get-Command git -ErrorAction SilentlyContinue)
if (-not $gitAvailable) {
    Write-Warn2 "git was not found on PATH. clone-skill entries will be skipped."
}

# Summary trackers
$installed = New-Object System.Collections.Generic.List[string]
$skipped   = New-Object System.Collections.Generic.List[string]
$failed    = New-Object System.Collections.Generic.List[string]
$manualSteps = New-Object System.Collections.Generic.List[string]

$lines = Get-Content -LiteralPath $ManifestPath | Where-Object {
    ($_ -notmatch '^\s*#') -and ($_.Trim() -ne '')
}

foreach ($line in $lines) {
    $parts = $line -split "`t"
    if ($parts.Count -lt 3) {
        Write-Warn2 "Skipping malformed manifest line: $line"
        continue
    }

    $method = $parts[0].Trim()
    $repo   = $parts[1].Trim()
    $note   = ($parts[2..($parts.Count - 1)] -join "`t").Trim()

    switch ($method) {

        'clone-skill' {
            if (-not $gitAvailable) {
                Write-Warn2 "Skipping $repo (git unavailable)."
                $failed.Add("$repo (git unavailable)") | Out-Null
                continue
            }

            # target name is the text before " :: " in the note field, or the repo's
            # own name if no override was given
            $target = ($note -split '::')[0].Trim()
            if ([string]::IsNullOrWhiteSpace($target)) {
                $target = ($repo -split '/')[-1]
            }

            $destDir = Join-Path $SkillsDir $target

            if (Test-Path -LiteralPath $destDir) {
                Write-Warn2 "Skipping $repo -> already installed at $destDir (not overwritten)."
                $skipped.Add("$repo -> $destDir") | Out-Null
                continue
            }

            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("skill-clone-" + [guid]::NewGuid().ToString('N'))
            try {
                Write-Info "Cloning $repo (shallow) ..."
                & git clone --depth 1 --quiet "https://github.com/$repo.git" $tempDir | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    throw "git clone failed for $repo"
                }

                # Find directories that contain a SKILL.md
                $skillDirs = Get-ChildItem -LiteralPath $tempDir -Recurse -Filter 'SKILL.md' -File -ErrorAction SilentlyContinue |
                    ForEach-Object { $_.Directory } |
                    Sort-Object FullName -Unique

                if ($skillDirs -and $skillDirs.Count -gt 0) {
                    if ($skillDirs.Count -eq 1) {
                        Write-Info "Copying skill folder for $repo into $destDir ..."
                        Copy-Item -LiteralPath $skillDirs[0].FullName -Destination $destDir -Recurse
                        Write-Ok "Installed $repo -> $destDir"
                        $installed.Add("$repo -> $destDir") | Out-Null
                    }
                    else {
                        # Multiple SKILL.md dirs found (e.g. a bundle repo): copy each
                        # under its own subfolder name inside a parent named after $target
                        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                        foreach ($sd in $skillDirs) {
                            $sub = Join-Path $destDir $sd.Name
                            if (Test-Path -LiteralPath $sub) {
                                Write-Warn2 "  Sub-skill already exists, skipping: $sub"
                                continue
                            }
                            Copy-Item -LiteralPath $sd.FullName -Destination $sub -Recurse
                        }
                        Write-Ok "Installed $repo (multiple skills) -> $destDir"
                        $installed.Add("$repo -> $destDir (multiple skill dirs, cherry-pick as needed)") | Out-Null
                    }
                }
                else {
                    Write-Info "No SKILL.md found in $repo; copying whole repo into $destDir ..."
                    Copy-Item -LiteralPath $tempDir -Destination $destDir -Recurse
                    Write-Ok "Installed $repo -> $destDir (whole repo)"
                    $installed.Add("$repo -> $destDir (whole repo, no SKILL.md detected)") | Out-Null
                }

                if ($note -match '::') {
                    Write-Warn2 "  Note for $repo`: $($note.Substring($note.IndexOf('::') + 2).Trim())"
                }
            }
            catch {
                Write-Err2 "Failed to install $repo`: $($_.Exception.Message)"
                $failed.Add("$repo ($($_.Exception.Message))") | Out-Null
            }
            finally {
                if (Test-Path -LiteralPath $tempDir) {
                    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }

        { $_ -in 'pip', 'npm' } {
            $cmd = (($note -split '::')[0]).Trim()
            Write-Info "$method step for $repo`: $cmd"

            if ($cmd -match '<.*>' -or $cmd -match '[()]') {
                Write-Warn2 "  Command contains a <placeholder> or prose - cannot run automatically."
                $manualSteps.Add("[$repo] ($method - fill in placeholder and run manually) $cmd") | Out-Null
            }
            else {
                $cmdArgs = $cmd -split '\s+' | Where-Object { $_ -ne '' }
                $exe = $cmdArgs[0]
                if ($exe -in 'pip', 'pip3', 'npm') {
                    try {
                        Write-Info "Running: $cmd"
                        if ($cmdArgs.Count -gt 1) {
                            & $exe @($cmdArgs[1..($cmdArgs.Count - 1)])
                        }
                        else {
                            & $exe
                        }
                        if ($LASTEXITCODE -ne 0) {
                            throw "$exe exited with code $LASTEXITCODE"
                        }
                        Write-Ok "Ran $method install step for $repo"
                        $installed.Add("$repo ($method`: $cmd)") | Out-Null
                    }
                    catch {
                        Write-Err2 "$method step failed for $repo`: $($_.Exception.Message)"
                        $failed.Add("$repo ($method step failed)") | Out-Null
                    }
                }
                else {
                    Write-Warn2 "  Command does not start with pip/pip3/npm - not running automatically."
                    $manualSteps.Add("[$repo] ($method - review and run manually) $cmd") | Out-Null
                }
            }
        }

        'mcp' {
            Write-Info "mcp step for $repo`: $note"
            if ($note -match '<.*>') {
                Write-Warn2 "This command likely needs a repo-specific command/URL filled in - review before running."
            }
            $manualSteps.Add("[$repo] (mcp - review and run manually) $note") | Out-Null
        }

        'plugin' {
            $manualSteps.Add("[$repo] (in-app plugin step) $note") | Out-Null
        }

        'manual' {
            $manualSteps.Add("[$repo] (manual) $note") | Out-Null
        }

        default {
            Write-Warn2 "Unknown method '$method' for $repo - treating as manual."
            $manualSteps.Add("[$repo] (unknown method '$method') $note") | Out-Null
        }
    }
}

Write-Host ""
Write-Host "==================== SUMMARY ====================" -ForegroundColor Cyan
Write-Host ("Installed : {0}" -f $installed.Count)
$installed | ForEach-Object { Write-Host "  - $_" }
Write-Host ("Skipped (already present) : {0}" -f $skipped.Count)
$skipped | ForEach-Object { Write-Host "  - $_" }
Write-Host ("Failed : {0}" -f $failed.Count)
$failed | ForEach-Object { Write-Host "  - $_" }
Write-Host "===================================================" -ForegroundColor Cyan

if ($manualSteps.Count -gt 0) {
    Write-Host ""
    Write-Host "The following steps are NOT scriptable and must be run inside Claude Code (or by hand):" -ForegroundColor Cyan
    $i = 1
    foreach ($step in $manualSteps) {
        Write-Host ("  {0}. {1}" -f $i, $step)
        $i++
    }
}

Write-Host ""
Write-Info "Done. Re-run this script any time - it will skip anything already installed."
