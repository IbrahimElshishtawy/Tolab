# ======================================
# Create TOLAB Structure Inside lib/
# ======================================

$root = "lib"

# Ensure root lib exists
New-Item -ItemType Directory -Path $root -Force -ErrorAction SilentlyContinue | Out-Null

# Ensure apps/ and packages/ under lib
$rootDirs = @(
    "$root\apps",
    "$root\packages"
)

foreach ($dir in $rootDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

# =========================================
# 1) Apps inside lib/apps (Mobile & Desktop + Regular & Dashboard)
# =========================================

$apps = @(
    "tolab_student_mobile", "tolab_student_desktop",
    "tolab_doctor_mobile", "tolab_doctor_desktop"
)

# Define app types: regular, dashboard
$appTypes = @("regular", "dashboard")

foreach ($app in $apps) {
    $baseDir = Join-Path $root "apps\$app"
    $srcDir  = Join-Path $baseDir "lib\src"
    
    # Create platform-specific directories for mobile/desktop
    $platforms = @("mobile", "desktop")
    foreach ($platform in $platforms) {
        $platformDir = Join-Path $srcDir $platform
        New-Item -ItemType Directory -Path $platformDir -Force -ErrorAction SilentlyContinue | Out-Null

        # Create base structure within each platform
        New-Item -ItemType Directory -Path (Join-Path $platformDir "config") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $platformDir "services") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $platformDir "notifications") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $platformDir "offline") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $platformDir "local_storage") -Force -ErrorAction SilentlyContinue | Out-Null
    }

    # Create app type-specific directories (regular, dashboard)
    foreach ($type in $appTypes) {
        $typeDir = Join-Path $srcDir $type
        New-Item -ItemType Directory -Path $typeDir -Force -ErrorAction SilentlyContinue | Out-Null

        # Inside each type, create platform-specific subdirectories for UI, layouts, widgets, etc.
        New-Item -ItemType Directory -Path (Join-Path $typeDir "ui") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $typeDir "widgets") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $typeDir "layouts") -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $typeDir "features") -Force -ErrorAction SilentlyContinue | Out-Null
    }
}

# ====================================
# 2) Admin Panel App inside lib/apps
# ====================================

$adminApp = "tolab_admin_panel"
$adminBase = Join-Path $root "apps\$adminApp"
$adminSrcBase = Join-Path $adminBase "lib\src"

# Admin panel directories
$adminDirs = @(
    $adminBase,
    "$adminBase\lib",
    $adminSrcBase,
    "$adminSrcBase\config",
    "$adminSrcBase\di",
    "$adminSrcBase\services",
    "$adminSrcBase\notifications",
    "$adminSrcBase\local_storage",
    "$adminSrcBase\presentation",
    "$adminSrcBase\localization\arb",
    "$adminBase\test"
)

foreach ($dir in $adminDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

# Features inside the Admin Panel (Dashboard type)
$adminFeaturesList = @(
    "auth",
    "dashboard",
    "students_management",
    "subjects_management",
    "schedule_management",
    "community_moderation",
    "notifications_management",
    "settings",
    "common"
)

# Create directories for each admin feature
foreach ($feature in $adminFeaturesList) {
    $featureBase = Join-Path $adminSrcBase "presentation\features\$feature"
    $cubitDir    = Join-Path $featureBase "cubit"
    $pagesDir    = Join-Path $featureBase "pages"
    $widgetsDir  = Join-Path $featureBase "widgets"
    
    $dirs = @($featureBase, $cubitDir, $pagesDir, $widgetsDir)
    foreach ($d in $dirs) {
        New-Item -ItemType Directory -Path $d -Force -ErrorAction SilentlyContinue | Out-Null
    }
}

# =======================================
# 3) Package: tolab_core (lib/packages)
# =======================================

$coreBase = Join-Path $root "packages\tolab_core"
$coreLib = Join-Path $coreBase "lib"
$coreTest = Join-Path $coreBase "test"

$coreDirs = @(
    $coreBase,
    $coreLib,
    "$coreLib\errors",
    "$coreLib\network",
    "$coreLib\utils",
    "$coreLib\constants",
    "$coreLib\platform",
    $coreTest,
    "$coreTest\errors",
    "$coreTest\network",
    "$coreTest\utils"
)

foreach ($dir in $coreDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

# =======================================
# 4) Package: tolab_domain (lib/packages)
# =======================================

$domainBase = Join-Path $root "packages\tolab_domain"
$domainLib = Join-Path $domainBase "lib"
$domainTest = Join-Path $domainBase "test"

$domainDirs = @(
    $domainBase,
    $domainLib,
    "$domainLib\entities",
    "$domainLib\value_objects",
    "$domainLib\repositories",
    "$domainLib\usecases",
    $domainTest,
    "$domainTest\usecases",
    "$domainTest\value_objects"
)

foreach ($dir in $domainDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

# =======================================
# 5) Package: tolab_data (lib/packages)
# =======================================

$dataBase = Join-Path $root "packages\tolab_data"
$dataLib = Join-Path $dataBase "lib"
$dataTest = Join-Path $dataBase "test"
$dataDS = "$dataLib\datasources"

$dataDirs = @(
    $dataBase,
    $dataLib,
    "$dataLib\models",
    $dataDS,
    "$dataDS\remote",
    "$dataDS\local",
    "$dataDS\mappers",
    "$dataLib\repositories_impl",
    "$dataLib\api_client",
    "$dataLib\api_client\interceptors",
    "$dataLib\offline",
    $dataTest,
    "$dataTest\repositories_impl",
    "$dataTest\datasources",
    "$dataTest\datasources\remote",
    "$dataTest\datasources\local",
    "$dataTest\offline"
)

foreach ($dir in $dataDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

# =======================================
# 6) Package: tolab_ui_kit (lib/packages)
# =======================================

$uiBase = Join-Path $root "packages\tolab_ui_kit"
$uiLib = Join-Path $uiBase "lib"
$uiTest = Join-Path $uiBase "test"

$uiDirs = @(
    $uiBase,
    $uiLib,
    "$uiLib\buttons",
    "$uiLib\inputs",
    "$uiLib\cards",
    "$uiLib\dialogs",
    "$uiLib\typography",
    "$uiLib\responsive",
    $uiTest,
    "$uiTest\widgets"
)

foreach ($dir in $uiDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "TOLAB folder structure created successfully under '$root'."
