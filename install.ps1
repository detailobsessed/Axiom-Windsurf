# Axiom Skills Installer for Windsurf Next (Windows)
#
# Usage:
#   powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/detailobsessed/Axiom-Windsurf/main/install.ps1 | iex"
#
# Or with a specific version:
#   powershell -ExecutionPolicy ByPass -c "$env:AXIOM_WINDSURF_VERSION='v1.0.0'; irm https://raw.githubusercontent.com/detailobsessed/Axiom-Windsurf/main/install.ps1 | iex"

param(
    [string]$Version = ""
)

# Support env var for pipe-to-iex usage
if (-not $Version) {
    $Version = $env:AXIOM_WINDSURF_VERSION
}

$ErrorActionPreference = "Stop"

# Configuration
$Repo = "detailobsessed/Axiom-Windsurf"
$Branch = "main"
$SkillsDir = Join-Path $env:USERPROFILE ".codeium\windsurf-next\skills"
$WorkflowsDir = Join-Path $env:USERPROFILE ".codeium\windsurf-next\global_workflows"
$WorkflowsNew = 0
$WorkflowsUpdated = 0

function Write-ColorOutput($ForegroundColor, $Message) {
    Write-Host -ForegroundColor $ForegroundColor -Object $Message
}

# Header
Write-Output ""
Write-Output "Axiom Skills Installer for Windsurf Next"
Write-Output "========================================="
Write-Output ""

# Determine download URL
if ($Version) {
    $DownloadUrl = "https://github.com/$Repo/archive/refs/tags/$Version.zip"
    # GitHub strips 'v' prefix from archive folder names
    $ArchivePrefix = "Axiom-Windsurf-$($Version.TrimStart('v'))"
    Write-Output "Downloading Axiom Skills $Version..."
} else {
    $DownloadUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    $ArchivePrefix = "Axiom-Windsurf-$Branch"
    Write-Output "Downloading Axiom Skills (latest)..."
}

# Create temp directory
$TempDir = Join-Path $env:TEMP "axiom-install-$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$ArchivePath = Join-Path $TempDir "axiom.zip"

try {
    # Download
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchivePath -UseBasicParsing
    } catch {
        Write-ColorOutput Red "Error: Failed to download from $DownloadUrl"
        if ($Version) {
            Write-ColorOutput Red "Make sure version '$Version' exists."
        }
        exit 1
    }

    # Extract
    Write-Output "Extracting..."
    Expand-Archive -Path $ArchivePath -DestinationPath $TempDir -Force

    $ExtractedDir = Join-Path $TempDir $ArchivePrefix
    if (-not (Test-Path $ExtractedDir)) {
        $ExtractedDir = Get-ChildItem -Path $TempDir -Directory |
            Where-Object { $_.Name -like "Axiom-Windsurf-*" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1 |
            ForEach-Object FullName
    }
    $SourceSkills = Join-Path $ExtractedDir "skills"
    $SourceWorkflows = Join-Path $ExtractedDir ".windsurf\workflows"

    if (-not (Test-Path $SourceSkills)) {
        Write-ColorOutput Red "Error: Skills directory not found in archive."
        exit 1
    }

    # Create target directory
    if (-not (Test-Path $SkillsDir)) {
        Write-ColorOutput Yellow "Creating Windsurf skills directory..."
        New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    }

    # Count skills
    $SkillDirs = Get-ChildItem -Path $SourceSkills -Directory
    $SkillCount = $SkillDirs.Count

    Write-Output "Skills:    $SkillsDir"
    Write-Output "Workflows: $WorkflowsDir"
    Write-Output ""

    # Install skills
    $Installed = 0
    $Updated = 0
    foreach ($SkillDir in $SkillDirs) {
        $TargetSkillDir = Join-Path $SkillsDir $SkillDir.Name

        if (Test-Path $TargetSkillDir) {
            # Atomic update: backup, copy, then remove backup on success
            $BackupDir = "${TargetSkillDir}.bak"
            Move-Item -Path $TargetSkillDir -Destination $BackupDir -Force
            try {
                Copy-Item -Path $SkillDir.FullName -Destination $TargetSkillDir -Recurse
                Remove-Item -Path $BackupDir -Recurse -Force
                $Updated++
            } catch {
                # Restore on failure
                Move-Item -Path $BackupDir -Destination $TargetSkillDir -Force
                Write-ColorOutput Yellow "Failed to update $($SkillDir.Name)"
            }
        } else {
            Copy-Item -Path $SkillDir.FullName -Destination $TargetSkillDir -Recurse
            $Installed++
        }
    }

    # Copy workflows to global workflows directory
    if (Test-Path $SourceWorkflows) {
        New-Item -ItemType Directory -Path $WorkflowsDir -Force | Out-Null
        $WorkflowFiles = Get-ChildItem -Path $SourceWorkflows -Filter "*.md"
        foreach ($Workflow in $WorkflowFiles) {
            $TargetWorkflow = Join-Path $WorkflowsDir $Workflow.Name
            if (Test-Path $TargetWorkflow) {
                try {
                    Copy-Item -Path $Workflow.FullName -Destination $WorkflowsDir -Force
                    $WorkflowsUpdated++
                } catch {
                    Write-ColorOutput Yellow "Failed to update workflow $($Workflow.Name)"
                }
            } else {
                try {
                    Copy-Item -Path $Workflow.FullName -Destination $WorkflowsDir -Force
                    $WorkflowsNew++
                } catch {
                    Write-ColorOutput Yellow "Failed to install workflow $($Workflow.Name)"
                }
            }
        }
    }

    # Validate installation
    if (($Installed + $Updated) -eq 0) {
        Write-ColorOutput Red "Error: No skills were installed."
        exit 1
    }

    # Summary
    Write-Output ""
    Write-ColorOutput Green "Done!"
    Write-Output ""
    Write-Output "  Skills new:       $Installed"
    Write-Output "  Skills updated:   $Updated"
    Write-Output "  Workflows new:    $WorkflowsNew"
    Write-Output "  Workflows updated: $WorkflowsUpdated"
    Write-Output ""
    Write-Output "Skills are now available in Windsurf Next."
    Write-Output "You may need to restart Windsurf for changes to take effect."
    Write-Output ""

} finally {
    # Cleanup
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
