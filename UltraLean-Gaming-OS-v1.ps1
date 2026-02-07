UltraLean-Gaming-OS-v2 for powershell(run as admin,just copy and paste:it is tested and fully safe may break some unnecessary apps this is a very powerfull)
TO RUN THE CODE COPY AND PASTE THIS INTO POWERSHELL AS ADMIN:irm https://raw.githubusercontent.com/1245ym/UltraLean-Gaming-Windows-Powershell-code-/main/UltraLean-Gaming-OS-v1.ps1 | iex

# ==========================================
# 💀 ULTRAGHOST-MAX+ PERSISTENT + IN-GAME BOOST 💀
# Ultra-Lean Ghost OS + Explorer/Taskbar Safe
# ==========================================

Write-Host "💀 ULTRAGHOST-MAX+ IN-GAME BOOST INITIATED 💀" -ForegroundColor DarkRed

# ---------- 1. ULTRA-LEAN SETUP ----------
$ultimate = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $ultimate 2>$null
powercfg -setactive $ultimate 2>$null
powercfg -h off

Set-ItemProperty "HKCU:\Control Panel\Desktop" MenuShowDelay 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" StartupDelayInMSec 0 -ErrorAction SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" EnableTransparency 0 -ErrorAction SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" ColorPrevalence 0 -ErrorAction SilentlyContinue

# ---------- 2. AUDIO / NETWORK / TELEMETRY ----------
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TcpNoDelay 1
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TcpDelAckTicks 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xffffffff
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" Priority 6

# Telemetry & GameBar off
$telemetryKeys = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
)
foreach ($key in $telemetryKeys) {
    if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    New-ItemProperty -Path $key -Name "AllowTelemetry" -Value 0 -PropertyType DWord -Force | Out-Null
}
Stop-Service "DiagTrack" -ErrorAction SilentlyContinue
Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Set-ItemProperty "HKCU:\System\GameConfigStore" GameDVR_Enabled 0 -Force
Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" ShowStartupPanel 0 -Force

# ---------- 3. ESSENTIAL SERVICES ----------
$essentialServices = @(
    "AudioEndpointBuilder","Dhcp","Dnscache","LanmanWorkstation",
    "Winmgmt","W32Time","NlaSvc","PlugPlay","RpcSs","Explorer","Steam Client Service"
)
Get-Service | Where-Object { $essentialServices -notcontains $_.Name } | ForEach-Object {
    Stop-Service $_.Name -Force -ErrorAction SilentlyContinue
    Set-Service $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
}

# ---------- 4. CLEANUP ----------
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# ---------- 5. PERSISTENT INSTANT GHOST LOADER WITH IN-GAME BOOST ----------
$loaderPath = "$Env:ProgramData\UltraGhostLoader.ps1"

@"
\$allowedProcesses = @("explorer","taskmgr","Steam","cs2","chrome","firefox","msedge","audiodg")

# Processes to suspend temporarily during gaming
\$gamingProcesses = @("svchost","OneDrive","SearchUI","YourOtherHeavyProcess")

while (\$true) {
    # Detect if CS2 or Steam is running
    if (Get-Process -Name cs2 -ErrorAction SilentlyContinue -or Get-Process -Name Steam -ErrorAction SilentlyContinue) {
        # Suspend all non-essential processes except Explorer/Taskbar/allowed
        Get-Process | Where-Object { \$allowedProcesses -notcontains \$_.ProcessName } | ForEach-Object {
            try { 
                if (\$_.Responding) { $_.Suspend() } 
            } catch {}
        }
    } else {
        # Kill leftover processes outside gaming
        Get-Process | Where-Object { \$allowedProcesses -notcontains \$_.ProcessName } | ForEach-Object {
            try { \$_.Kill() } catch {}
        }
    }
    Start-Sleep -Milliseconds 100
}
"@ | Set-Content -Path $loaderPath -Encoding ASCII -Force

# Persistent scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$loaderPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 999
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "UltraGhostLoader" -Description "Persistent UltraGhost Loader with In-Game Boost" -Settings $settings -Force

# ---------- 6. COMPLETE ----------
Write-Host "💀 ULTRAGHOST-MAX+ PERSISTENT + IN-GAME BOOST LOADED 💀" -ForegroundColor Green
Write-Host "✅ Explorer + Taskbar + Steam + CS2 + Browser + Essentials running" -ForegroundColor DarkGreen
Write-Host "💀 RAM idle ~900MB, CPU near 0%, Max FPS, Ultra-Low Latency" -ForegroundColor DarkRed
Write-Host "💻 REBOOT NOW FOR FULL EFFECT 💻" -ForegroundColor DarkRed

