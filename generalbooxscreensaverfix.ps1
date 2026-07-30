# ============================================================================== #
# UNIVERSAL BOOX FACTORY-ART BLOCKER & SCREENSAVER SYNCER (ANTI-CLOSE EDITION)  #
# ============================================================================== #

# Helper function to display critical errors and freeze the window
function Stop-Script {
    param (
        [string]$ErrorMessage,
        [string]$Suggestion
    )
    Write-Host "`nCRITICAL ERROR: $ErrorMessage" -ForegroundColor Red
    Write-Host "SUGGESTION: $Suggestion" -ForegroundColor Cyan
    Write-Host "`nPress any key to close this window..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit
}

# --- PRIVILEGE CHECK ---
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Stop-Script `
        -ErrorMessage "This script requires Administrator privileges to run." `
        -Suggestion "Right-click your PowerShell icon (or the script file) and select 'Run as Administrator'."
}

# --- STEP 1: AUTOMATICALLY LOCATE ADB ---
Write-Host "Locating ADB execution environment..." -ForegroundColor Yellow
$AdbPath = ""
$SearchPaths = @(
    "C:\tools\platform-tools\adb.exe",
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "C:\Program Files (x86)\Minimal ADB and Fastboot\adb.exe",
    "C:\platform-tools\adb.exe"
)

if (Get-Command adb -ErrorAction SilentlyContinue) {
    $AdbPath = (Get-Command adb).Source
} else {
    foreach ($Path in $SearchPaths) {
        if (Test-Path $Path) { $AdbPath = $Path; break }
    }
}

if (-not $AdbPath) {
    Stop-Script `
        -ErrorMessage "adb.exe could not be found automatically." `
        -Suggestion "Please place your platform-tools folder in C:\tools\ or add it to your Windows System PATH."
}
Write-Host "--> Found active ADB environment at: $AdbPath" -ForegroundColor Gray


# --- STEP 2: VERIFY AND INITIALIZE DEVICE CONNECTION ---
Write-Host "`nChecking USB connection to your Boox e-Reader..." -ForegroundColor Yellow
$Devices = & $AdbPath devices | Where-Object { $_ -match '\bdevice\b' }

if ($Devices.Count -eq 0) {
    Stop-Script `
        -ErrorMessage "No responsive Android devices detected." `
        -Suggestion "Please ensure USB Debugging is enabled on your Boox and the cable is connected securely."
}
Write-Host "--> Active Boox device detected successfully." -ForegroundColor Green


# --- STEP 3: DYNAMIC CONFIGURATION OVERRIDE ---
Write-Host "`nConfiguring Onyx Settings Database..." -ForegroundColor Yellow
$DeviceUserPath = "/sdcard/Pictures/Screensaver"
& $AdbPath shell mkdir -p "$DeviceUserPath" 2>$null

# Scan for custom images inside the directory
$RawImages = & $AdbPath shell ls "$DeviceUserPath/*.png" "$DeviceUserPath/*.jpg" 2>$null

if (-not $RawImages) {
    Stop-Script `
        -ErrorMessage "No custom artwork (.png/.jpg) found at $DeviceUserPath" `
        -Suggestion "Please copy your custom screensaver images to that device folder and re-run this script."
}

$CleanedPaths = $RawImages | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
$JoinedPaths = $CleanedPaths -join ","

# Push database keys to device
& $AdbPath shell settings put system onyx_screen_saver_choose_image_path "$JoinedPaths"
& $AdbPath shell settings put system onyx_screen_saver_custom_images "$JoinedPaths"
& $AdbPath shell settings put system onyx_screen_saver_choose_image_path "'$JoinedPaths'"
& $AdbPath shell settings put system onyx_screen_saver_custom_images "'$JoinedPaths'"
& $AdbPath shell settings put system onyx_screen_saver_default_image_path ""
& $AdbPath shell settings put system onyx_screen_saver_default_image_path "''"
& $AdbPath shell settings put system onyx_screen_saver_type 2

Write-Host "--> Success! Armed $($CleanedPaths.Count) screensavers across all cross-platform system keys." -ForegroundColor Green


# --- STEP 4: REFRESH SYSTEM GRAPHICS LAYER ---
Write-Host "`nFlushing cached system factory assets..." -ForegroundColor Yellow
& $AdbPath shell am force-stop com.onyx.android.contentmanager
& $AdbPath shell am force-stop com.onyx.android.screensaver 2>$null
& $AdbPath shell am broadcast -a android.intent.action.WALLPAPER_CHANGED 2>$null

Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "PROCESS FINISHED: Tap the power button twice to sleep/wake your device and test!" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green

# Freeze the window on a successful run too
Write-Host "`nPress any key to close this window..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
