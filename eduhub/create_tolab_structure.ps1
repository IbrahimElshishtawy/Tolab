# ===========================================
#  TOLAB PROJECT CLEANUP SCRIPT (DASHBOARD + REGULAR)
#  - Tries to move remaining content
#  - Deletes dashboard/regular if they have NO files
#  - Creates backup before changes
# ===========================================

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== Starting TOLAB CLEANUP ===" -ForegroundColor Cyan

function New-SafeDir {
    param([string]$path)
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}

function Move-Safe {
    param(
        [string]$source,
        [string]$target
    )
    if (Test-Path $source) {
        New-SafeDir $target
        Move-Item "$source\*" $target -Force -ErrorAction SilentlyContinue
    }
}

# -------------------------------------------------------------------------
# Detect project root
# -------------------------------------------------------------------------
$scriptDir = Split-Path -Parent $PSCommandPath
$libRoot   = Join-Path $scriptDir "lib"

if (!(Test-Path $libRoot)) {
    Write-Host "ERROR: Cannot find 'lib' next to script." -ForegroundColor Red
    exit
}

# -------------------------------------------------------------------------
# Backup (apps only هذه المرة)
# -------------------------------------------------------------------------
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRoot = Join-Path $scriptDir "_cleanup_backup_$timestamp"

Write-Host "Creating cleanup backup: $backupRoot" -ForegroundColor Yellow
New-SafeDir $backupRoot

Copy-Item (Join-Path $libRoot "apps") (Join-Path $backupRoot "apps") -Recurse -Force

Write-Host "Backup for cleanup completed." -ForegroundColor Green

# -------------------------------------------------------------------------
# Apps to process (non-admin)
# -------------------------------------------------------------------------
$appNames = @(
    "tolab_doctor_desktop",
    "tolab_doctor_mobile",
    "tolab_student_desktop",
    "tolab_student_mobile"
)

foreach ($appName in $appNames) {

    Write-Host "`nProcessing app (cleanup): $appName" -ForegroundColor Cyan

    $appSrc = Join-Path $libRoot "apps\$appName\lib\src"
    if (!(Test-Path $appSrc)) {
        Write-Host "Skipping (src not found): $appSrc" -ForegroundColor DarkGray
        continue
    }

    $featuresPath     = Join-Path $appSrc "features"
    $presentationPath = Join-Path $appSrc "presentation"
    $presentDesktop   = Join-Path $presentationPath "desktop"
    $presentMobile    = Join-Path $presentationPath "mobile"
    $presentShared    = Join-Path $presentationPath "shared"

    New-SafeDir $featuresPath
    New-SafeDir $presentDesktop
    New-SafeDir $presentMobile
    New-SafeDir $presentShared

    # ======================== regular/ ===========================
    $regularRoot = Join-Path $appSrc "regular"
    if (Test-Path $regularRoot) {

        Write-Host " - Cleaning regular/ ..." -ForegroundColor Yellow

        Move-Safe (Join-Path $regularRoot "features") (Join-Path $featuresPath "common")
        Move-Safe (Join-Path $regularRoot "layouts")  (Join-Path $presentShared "layouts")
        Move-Safe (Join-Path $regularRoot "ui")       (Join-Path $presentShared "ui")
        Move-Safe (Join-Path $regularRoot "widgets")  (Join-Path $presentShared "widgets")

        # Check if regular has any FILES (not just empty dirs)
        $files = @(Get-ChildItem $regularRoot -Recurse -File -Force)
        if ($files.Count -eq 0) {
            Write-Host "   > Removing empty regular/ folder" -ForegroundColor DarkGray
            Remove-Item $regularRoot -Recurse -Force
        } else {
            Write-Host "   > regular/ still has files, kept." -ForegroundColor Yellow
        }
    }

    # ======================== dashboard/ ==========================
    $dashboardRoot = Join-Path $appSrc "dashboard"
    if (Test-Path $dashboardRoot) {

        Write-Host " - Cleaning dashboard/ ..." -ForegroundColor Yellow

        # إعادة المحاولة في تنظيمه
        Move-Safe (Join-Path $dashboardRoot "features") (Join-Path $featuresPath "dashboard")

        $isDesktop = $appName -like "*desktop"
        $uiTarget  = if ($isDesktop) { $presentDesktop } else { $presentMobile }

        Move-Safe (Join-Path $dashboardRoot "layouts")  (Join-Path $uiTarget "dashboard/layouts")
        Move-Safe (Join-Path $dashboardRoot "ui")       (Join-Path $uiTarget "dashboard/ui")
        Move-Safe (Join-Path $dashboardRoot "widgets")  (Join-Path $uiTarget "dashboard/widgets")

        # Check if dashboard has any FILES (not فقط فولدرات)
        $files = @(Get-ChildItem $dashboardRoot -Recurse -File -Force)
        if ($files.Count -eq 0) {
            Write-Host "   > Removing empty dashboard/ folder" -ForegroundColor DarkGray
            Remove-Item $dashboardRoot -Recurse -Force
        } else {
            Write-Host "   > dashboard/ still has files, kept." -ForegroundColor Yellow
        }
    }

    Write-Host "Cleanup finished for app: $appName" -ForegroundColor Green
}

Write-Host "`n=== TOLAB CLEANUP COMPLETED ===" -ForegroundColor Cyan
Write-Host "Cleanup backup saved at: $backupRoot" -ForegroundColor Yellow
