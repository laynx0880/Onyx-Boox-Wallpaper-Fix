# ==============================================================================
# UNIVERSAL BOOX FACTORY-ART BLOCKER & SCREENSAVER SYNCER
# ==============================================================================
# Community Solution: Forces Boox devices to only rotate user-provided images.
# Works across modern Onyx firmware updates (Android 9 through Android 11+).
# ==============================================================================

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
    Write-Host "CRITICAL ERROR: adb.exe could not be found automatically." -ForegroundColor Red
    Write-Host "Please place your platform-tools folder in C:\tools\ or add it to your Windows System PATH." -ForegroundColor Cyan
    Exit
}
Write-Host "--> Found active ADB environment at: $AdbPath" -ForegroundColor Gray


# --- STEP 2: VERIFY AND INITIALIZE DEVICE CONNECTION ---
Write-Host "`nChecking USB connection to your Boox e-Reader..." -ForegroundColor Yellow
$Devices = & $AdbPath devices | Where-Object { $_ -match '\bdevice\b' }

if ($Devices.Count -eq 0) {
    Write-Host "CRITICAL ERROR: No responsive Android devices detected." -ForegroundColor Red
    Write-Host "Please ensure USB Debugging is enabled on your Boox and the cable is connected securely." -ForegroundColor Cyan
    Exit
}
Write-Host "--> Active Boox device detected successfully." -ForegroundColor Green


# --- STEP 3: DYNAMIC CONFIGURATION OVERRIDE (CROSS-PLATFORM COMPATIBILITY) ---
Write-Host "`nConfiguring Onyx Settings Database..." -ForegroundColor Yellow

# Define universal folder target and ensure it exists on the device
$DeviceUserPath = "/sdcard/Pictures/Screensaver"
& $AdbPath shell mkdir -p "$DeviceUserPath" 2>$null

# Scan for custom images inside the directory
$RawImages = & $AdbPath shell ls "$DeviceUserPath/*.png" "$DeviceUserPath/*.jpg" 2>$null

if (-not $RawImages) {
    Write-Host "CRITICAL ERROR: No custom artwork (.png/.jpg) found at $DeviceUserPath" -ForegroundColor Red
    Write-Host "Please copy your custom screensaver images to that device folder and re-run this script." -ForegroundColor Cyan
    Exit
}

# Clean white-space and trailing carriage returns returned from the Android shell layer
$CleanedPaths = $RawImages | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
$JoinedPaths = $CleanedPaths -join ","

# COMPATIBILITY LAYER: 
# Older firmware reads raw strings. Newer firmware (Android 11+) requires single-quoted literal arrays.
# We explicitly overwrite all variants to prevent fallback loops regardless of device model.
& $AdbPath shell settings put system onyx_screen_saver_choose_image_path "$JoinedPaths"
& $AdbPath shell settings put system onyx_screen_saver_custom_images "$JoinedPaths"
& $AdbPath shell settings put system onyx_screen_saver_choose_image_path "'$JoinedPaths'"
& $AdbPath shell settings put system onyx_screen_saver_custom_images "'$JoinedPaths'"

# Explicitly strip standard factory fallback strings
& $AdbPath shell settings put system onyx_screen_saver_default_image_path ""
& $AdbPath shell settings put system onyx_screen_saver_default_image_path "''"

# Mode '2' locks Content Manager exclusively into User Custom Loop Mode
& $AdbPath shell settings put system onyx_screen_saver_type 2

Write-Host "--> Success! Armed $($CleanedPaths.Count) screensavers across all cross-platform system keys." -ForegroundColor Green


# --- STEP 4: REFRESH SYSTEM GRAPHICS LAYER ---
Write-Host "`nFlushing cached system factory assets..." -ForegroundColor Yellow

# Force-stop background processes to flush old image lists out of active RAM
& $AdbPath shell am force-stop com.onyx.android.contentmanager
& $AdbPath shell am force-stop com.onyx.android.screensaver 2>$null

# Broadcast a system change intent to wake up the system UI paint engine
& $AdbPath shell am broadcast -a android.intent.action.WALLPAPER_CHANGED 2>$null

Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "PROCESS FINISHED: Tap the power button twice to sleep/wake your device and test!" -ForegroundColor Green
