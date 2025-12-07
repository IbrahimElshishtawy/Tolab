# ===========================================
#  TOLAB PROJECT REFACTOR SCRIPT (FINAL SAFE)
# ===========================================

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== Starting TOLAB SAFE REFACTOR ===" -ForegroundColor Cyan

function New-SafeDir {
    param([string]$path)
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}

$scriptDir = Split-Path -Parent $PSCommandPath
$libRoot   = Join-Path $scriptDir "lib"

if (!(Test-Path $libRoot)) {
    Write-Host "ERROR: Cannot find 'lib' next to script." -ForegroundColor Red
    exit
}

$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRoot = Join-Path $scriptDir "_backup_$timestamp"

Write-Host "Creating backup: $backupRoot" -ForegroundColor Yellow
New-SafeDir $backupRoot

Copy-Item (Join-Path $libRoot "apps")     (Join-Path $backupRoot "apps")     -Recurse -Force
Copy-Item (Join-Path $libRoot "packages") (Join-Path $backupRoot "packages") -Recurse -Force

Write-Host "Backup completed." -ForegroundColor Green

$appNames = @(
    "tolab_admin_panel",
    "tolab_doctor_desktop",
    "tolab_doctor_mobile",
    "tolab_student_desktop",
    "tolab_student_mobile"
)

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

foreach ($appName in $appNames) {

    Write-Host "`nProcessing app: $appName" -ForegroundColor Cyan

    $appSrc = Join-Path $libRoot "apps\$appName\lib\src"
    if (!(Test-Path $appSrc)) {
        Write-Host "Skipping (src not found): $appSrc" -ForegroundColor DarkGray
        continue
    }

    $corePath          = Join-Path $appSrc "core"
    $featuresPath      = Join-Path $appSrc "features"
    $presentationPath  = Join-Path $appSrc "presentation"
    $presentDesktop    = Join-Path $presentationPath "desktop"
    $presentMobile     = Join-Path $presentationPath "mobile"
    $presentShared     = Join-Path $presentationPath "shared"

    foreach ($folder in @($corePath,$featuresPath,$presentationPath,$presentDesktop,$presentMobile,$presentShared)) {
        New-SafeDir $folder
    }

    foreach ($extra in @("theme","utils","api","responsive")) {
        New-SafeDir (Join-Path $corePath $extra)
    }

    if ($appName -eq "tolab_admin_panel") {

        Write-Host "Admin Panel: Consolidating core folders..." -ForegroundColor Yellow

        foreach ($f in @("config","local_storage","notifications","services")) {
            $oldPath = Join-Path $appSrc $f
            if (Test-Path $oldPath) {
                Move-Safe $oldPath (Join-Path $corePath $f)
                Remove-Item $oldPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        Write-Host "Admin panel restructuring complete." -ForegroundColor Green
        continue
    }

    $platforms         = @("desktop","mobile")
    $commonTechFolders = @("config","local_storage","notifications","offline","services")

    foreach ($platform in $platforms) {

        $platformRoot = Join-Path $appSrc $platform

        if (!(Test-Path $platformRoot)) { continue }

        Write-Host "Found platform: $platformRoot" -ForegroundColor Yellow

        foreach ($f in $commonTechFolders) {
            $srcPath = Join-Path $platformRoot $f
            $dstPath = Join-Path (Join-Path $corePath $f) $platform
            Move-Safe $srcPath $dstPath
            Remove-Item $srcPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        $remaining = @(Get-ChildItem $platformRoot -Recurse -Force)
        if ($remaining.Count -eq 0) {
            Remove-Item $platformRoot -Recurse -Force
        }
    }

    $regularRoot = Join-Path $appSrc "regular"
    if (Test-Path $regularRoot) {

        Write-Host "Processing regular/ folder..." -ForegroundColor Yellow

        Move-Safe (Join-Path $regularRoot "features") (Join-Path $featuresPath "common")
        Move-Safe (Join-Path $regularRoot "layouts")  (Join-Path $presentShared "layouts")
        Move-Safe (Join-Path $regularRoot "ui")       (Join-Path $presentShared "ui")
        Move-Safe (Join-Path $regularRoot "widgets")  (Join-Path $presentShared "widgets")

        $remaining = @(Get-ChildItem $regularRoot -Recurse -Force)
        if ($remaining.Count -eq 0) {
            Remove-Item $regularRoot -Recurse -Force
        }
    }

    $dashboardRoot = Join-Path $appSrc "dashboard"
    if (Test-Path $dashboardRoot) {

        Write-Host "Processing dashboard/ folder..." -ForegroundColor Yellow

        Move-Safe (Join-Path $dashboardRoot "features") (Join-Path $featuresPath "dashboard")

        $isDesktop = $appName -like "*desktop"
        $uiTarget  = if ($isDesktop) { $presentDesktop } else { $presentMobile }

        Move-Safe (Join-Path $dashboardRoot "layouts")  (Join-Path $uiTarget "dashboard/layouts")
        Move-Safe (Join-Path $dashboardRoot "ui")       (Join-Path $uiTarget "dashboard/ui")
        Move-Safe (Join-Path $dashboardRoot "widgets")  (Join-Path $uiTarget "dashboard/widgets")

        $remaining = @(Get-ChildItem $dashboardRoot -Recurse -Force)
        if ($remaining.Count -eq 0) {
            Remove-Item $dashboardRoot -Recurse -Force
        }
    }

    Write-Host "Finished app: $appName" -ForegroundColor Green
}

$packagesRoot   = Join-Path $libRoot "packages"
$sharedPkgRoot  = Join-Path $packagesRoot "tolab_shared_features"
$sharedPkgLib   = Join-Path $sharedPkgRoot "lib"

Write-Host "`nCreating shared features package skeleton..." -ForegroundColor Cyan

New-SafeDir $sharedPkgRoot
New-SafeDir $sharedPkgLib

foreach ($sub in @("features","utils","widgets","theme")) {
    New-SafeDir (Join-Path $sharedPkgLib $sub)
}

Write-Host "Shared package ready." -ForegroundColor Green
Write-Host "`n=== TOLAB SAFE REFACTOR COMPLETED ===" -ForegroundColor Cyan
Write-Host "Backup saved at: $backupRoot" -ForegroundColor Yellow
