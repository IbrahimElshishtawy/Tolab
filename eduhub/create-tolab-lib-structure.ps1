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
# 1) Apps inside lib/apps
# =========================================

$apps = @(
    "tolab_student_mobile",
    "tolab_student_desktop",
    "tolab_doctor_mobile",
    "tolab_doctor_desktop"
)

# Features المشتركة في كل App
$commonFeatures = @(
    "auth",
    "home",
    "subjects",
    "schedule",
    "community",
    "notifications",
    "profile",
    "settings",
    "common"
)

foreach ($app in $apps) {

    $appBase      = Join-Path $root "apps\$app"
    $srcBase      = Join-Path $appBase "lib\src"
    $configBase   = Join-Path $srcBase "config"
    $diBase       = Join-Path $srcBase "di"
    $servicesBase = Join-Path $srcBase "services"
    $notifBase    = Join-Path $srcBase "notifications"
    $offlineBase  = Join-Path $srcBase "offline"
    $localBase    = Join-Path $srcBase "local_storage"
    $presentBase  = Join-Path $srcBase "presentation"
    $layoutsBase  = Join-Path $presentBase "layouts"
    $featuresBase = Join-Path $presentBase "features"
    $widgetsBase  = Join-Path $presentBase "widgets"
    $utilsBase    = Join-Path $presentBase "utils"
    $locBase      = Join-Path $srcBase "localization\arb"
    $testBase     = Join-Path $appBase "test"

    $appDirs = @(
        # app & lib/src
        $appBase,
        "$appBase\lib",
        $srcBase,
        # base layers
        $configBase,
        $diBase,
        $servicesBase,
        # notifications
        $notifBase,
        "$notifBase\fcm",
        "$notifBase\local",
        "$notifBase\models",
        # offline
        $offlineBase,
        "$offlineBase\cache",
        "$offlineBase\sync",
        "$offlineBase\observers",
        # local storage
        $localBase,
        "$localBase\hive",
        "$localBase\secure",
        "$localBase\preferences",
        # presentation
        $presentBase,
        $layoutsBase,
        $featuresBase,
        $widgetsBase,
        $utilsBase,
        # localization
        (Split-Path $locBase),
        $locBase,
        # tests
        $testBase,
        "$testBase\unit",
        "$testBase\widget",
        "$testBase\integration"
    )

    foreach ($dir in $appDirs) {
        New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
    }

    # إنشاء فولدرات الـ Features لكل App
    foreach ($feature in $commonFeatures) {
        $featureBase = Join-Path $featuresBase $feature
        $cubitDir    = Join-Path $featureBase "cubit"
        $pagesDir    = Join-Path $featureBase "pages"
        $widgetsDir  = Join-Path $featureBase "widgets"

        $dirs = @(
            $featureBase,
            $cubitDir,
            $pagesDir,
            $widgetsDir
        )

        foreach ($d in $dirs) {
            New-Item -ItemType Directory -Path $d -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }
}

# ====================================
# 2) Admin Panel App inside lib/apps
# ====================================

$adminApp       = "tolab_admin_panel"
$adminBase      = Join-Path $root "apps\$adminApp"
$adminSrcBase   = Join-Path $adminBase "lib\src"
$adminConfig    = Join-Path $adminSrcBase "config"
$adminDi        = Join-Path $adminSrcBase "di"
$adminServices  = Join-Path $adminSrcBase "services"
$adminNotif     = Join-Path $adminSrcBase "notifications"
$adminLocal     = Join-Path $adminSrcBase "local_storage"
$adminPresent   = Join-Path $adminSrcBase "presentation"
$adminLayouts   = Join-Path $adminPresent "layouts"
$adminFeatures  = Join-Path $adminPresent "features"
$adminWidgets   = Join-Path $adminPresent "widgets"
$adminUtils     = Join-Path $adminPresent "utils"
$adminLoc       = Join-Path $adminSrcBase "localization\arb"
$adminTest      = Join-Path $adminBase "test"

$adminDirs = @(
    $adminBase,
    "$adminBase\lib",
    $adminSrcBase,
    $adminConfig,
    $adminDi,
    $adminServices,
    # notifications
    $adminNotif,
    "$adminNotif\fcm",
    "$adminNotif\local",
    "$adminNotif\models",
    # local storage
    $adminLocal,
    "$adminLocal\hive",
    "$adminLocal\secure",
    "$adminLocal\preferences",
    # presentation
    $adminPresent,
    $adminLayouts,
    $adminFeatures,
    $adminWidgets,
    $adminUtils,
    # localization
    (Split-Path $adminLoc),
    $adminLoc,
    # tests
    $adminTest,
    "$adminTest\unit",
    "$adminTest\widget",
    "$adminTest\integration"
)

foreach ($dir in $adminDirs) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}

# Features خاصة بالأدمن
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

foreach ($feature in $adminFeaturesList) {
    $featureBase = Join-Path $adminFeatures $feature
    $cubitDir    = Join-Path $featureBase "cubit"
    $pagesDir    = Join-Path $featureBase "pages"
    $widgetsDir  = Join-Path $featureBase "widgets"

    $dirs = @(
        $featureBase,
        $cubitDir,
        $pagesDir,
        $widgetsDir
    )

    foreach ($d in $dirs) {
        New-Item -ItemType Directory -Path $d -Force -ErrorAction SilentlyContinue | Out-Null
    }
}

# ======================================
# 3) Package: tolab_core  (lib/packages)
# ======================================

$coreBase  = Join-Path $root "packages\tolab_core"
$coreLib   = Join-Path $coreBase "lib"
$coreTest  = Join-Path $coreBase "test"

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
# 4) Package: tolab_domain  (lib/packages)
# =======================================

$domainBase  = Join-Path $root "packages\tolab_domain"
$domainLib   = Join-Path $domainBase "lib"
$domainTest  = Join-Path $domainBase "test"

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

# ===================================
# 5) Package: tolab_data (lib/packages)
# ===================================

$dataBase   = Join-Path $root "packages\tolab_data"
$dataLib    = Join-Path $dataBase "lib"
$dataTest   = Join-Path $dataBase "test"
$dataDS     = "$dataLib\datasources"

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

$uiBase   = Join-Path $root "packages\tolab_ui_kit"
$uiLib    = Join-Path $uiBase "lib"
$uiTest   = Join-Path $uiBase "test"

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
