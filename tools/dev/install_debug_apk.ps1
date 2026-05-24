param(
    [string]$DeviceId = "emulator-5554",
    [string]$PackageName = "com.anpilov.dronestrike",
    [string]$ApkPath = "C:\Mobile Game Drone Strike\apps\mobile\build\app\outputs\flutter-apk\app-debug.apk",
    [switch]$CleanUserInstall,
    [switch]$TrimCaches,
    [switch]$KillEmulator,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Help {
    @"
Install FPV Last Run debug APK on an Android emulator.

Usage:
  .\tools\dev\install_debug_apk.ps1
  .\tools\dev\install_debug_apk.ps1 -CleanUserInstall
  .\tools\dev\install_debug_apk.ps1 -CleanUserInstall -TrimCaches

Options:
  -DeviceId <id>       Target adb device id. Default: emulator-5554
  -PackageName <name>  Android package name. Default: com.anpilov.dronestrike
  -ApkPath <path>      Debug APK path.
  -CleanUserInstall   Try safe package uninstall variants before install.
  -TrimCaches         Run pm trim-caches 999G before install.
  -KillEmulator       Kill the emulator at the end. Off by default.
  -Help               Show this help.

The script does not wipe emulator data automatically. If storage repair still
fails, wipe data manually in Android Studio Device Manager.
"@
}

function Resolve-AdbPath {
    $localAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
    if (Test-Path -LiteralPath $localAdb) {
        return $localAdb
    }

    $pathAdb = Get-Command "adb" -ErrorAction SilentlyContinue
    if ($null -ne $pathAdb) {
        return $pathAdb.Source
    }

    return $null
}

function Invoke-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    Write-Host ""
    Write-Host "==> $Label"
    Write-Host "$FilePath $($Arguments -join ' ')"

    $output = & $FilePath @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -eq 0) {
        Write-Host "Result: OK"
    } else {
        Write-Host "Result: FAILED (exit code $exitCode)"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = ($output -join "`n")
    }
}

function Invoke-Adb {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return Invoke-Tool -FilePath $script:AdbPath -Arguments $Arguments -Label $Label
}

if ($Help) {
    Show-Help
    exit 0
}

$script:AdbPath = Resolve-AdbPath
if ([string]::IsNullOrWhiteSpace($script:AdbPath)) {
    Write-Error "adb was not found. Install Android SDK Platform Tools or add adb to PATH."
    exit 1
}

if (-not (Test-Path -LiteralPath $ApkPath)) {
    Write-Error "APK was not found: $ApkPath"
    exit 1
}

Write-Host "ADB path: $script:AdbPath"
Write-Host "Device: $DeviceId"
Write-Host "APK: $ApkPath"
Write-Host "Package: $PackageName"

Write-Host ""
Write-Host "==> Connected devices"
$devicesOutput = & $script:AdbPath devices 2>&1
$devicesExitCode = $LASTEXITCODE
$devicesOutput | ForEach-Object { Write-Host $_ }
if ($devicesExitCode -ne 0) {
    Write-Error "Failed to query adb devices."
    exit $devicesExitCode
}

$escapedDeviceId = [regex]::Escape($DeviceId)
$targetDevice = $devicesOutput | Where-Object { $_ -match "^$escapedDeviceId\s+device\b" }
if ($null -eq $targetDevice) {
    Write-Host ""
    Write-Host "Target device '$DeviceId' was not found."
    Write-Host "Start Android Emulator first in Android Studio Device Manager."
    exit 1
}

if ($TrimCaches) {
    $trimResult = Invoke-Adb -Arguments @("-s", $DeviceId, "shell", "pm", "trim-caches", "999G") -Label "Trim emulator package caches"
    if ($trimResult.ExitCode -ne 0) {
        Write-Host "Continuing after trim-caches failure."
    }
}

if ($CleanUserInstall) {
    $uninstallCommands = @(
        @{
            Label = "adb uninstall"
            Args = @("-s", $DeviceId, "uninstall", $PackageName)
        },
        @{
            Label = "pm uninstall --user 0"
            Args = @("-s", $DeviceId, "shell", "pm", "uninstall", "--user", "0", $PackageName)
        },
        @{
            Label = "cmd package uninstall --user 0"
            Args = @("-s", $DeviceId, "shell", "cmd", "package", "uninstall", "--user", "0", $PackageName)
        }
    )

    foreach ($command in $uninstallCommands) {
        $uninstallResult = Invoke-Adb -Arguments $command.Args -Label $command.Label
        if ($uninstallResult.ExitCode -ne 0) {
            Write-Host "Continuing after uninstall attempt failure."
        }
    }
}

$installResult = Invoke-Adb -Arguments @("-s", $DeviceId, "install", "-r", "-d", $ApkPath) -Label "Install debug APK"

if ($installResult.ExitCode -ne 0 -and $installResult.Output -match "INSTALL_FAILED_INSUFFICIENT_STORAGE") {
    Write-Host ""
    Write-Host "Install failed because the emulator reports insufficient storage."
    Write-Host "Running pm trim-caches 999G and retrying once."
    $retryTrim = Invoke-Adb -Arguments @("-s", $DeviceId, "shell", "pm", "trim-caches", "999G") -Label "Trim emulator package caches before retry"
    if ($retryTrim.ExitCode -ne 0) {
        Write-Host "Continuing to retry install after trim-caches failure."
    }

    $installResult = Invoke-Adb -Arguments @("-s", $DeviceId, "install", "-r", "-d", $ApkPath) -Label "Retry install debug APK"
}

if ($installResult.ExitCode -ne 0) {
    Write-Host ""
    Write-Host "APK install failed."
    Write-Host "Next action:"
    Write-Host "  Android Studio -> Device Manager -> dropdown near emulator -> Wipe Data -> Start"
    Write-Host "This script does not wipe emulator data automatically."

    if ($KillEmulator) {
        $killResult = Invoke-Adb -Arguments @("-s", $DeviceId, "emu", "kill") -Label "Kill emulator"
        if ($killResult.ExitCode -ne 0) {
            Write-Host "Emulator kill command failed."
        }
    }

    exit $installResult.ExitCode
}

Write-Host ""
Write-Host "APK installed successfully."

if ($KillEmulator) {
    $killResult = Invoke-Adb -Arguments @("-s", $DeviceId, "emu", "kill") -Label "Kill emulator"
    if ($killResult.ExitCode -ne 0) {
        Write-Host "Emulator kill command failed."
        exit $killResult.ExitCode
    }
}

exit 0
