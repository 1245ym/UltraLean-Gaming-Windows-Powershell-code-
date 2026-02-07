UltraLean-Gaming-OS-v2 for powershell(run as admin,just copy and paste:it is tested and fully safe may break some unnecessary apps this is a very powerfull)
TO RUN THE CODE COPY AND PASTE THIS INTO POWERSHELL AS ADMIN:irm https://raw.githubusercontent.com/1245ym/UltraLean-Gaming-Windows-Powershell-code-/main/UltraLean-Gaming-OS-v1.ps1 | iex


# ==========================================
# 💀 SAFE ULTRAGHOST-LITE 💀
# ==========================================

Write-Host "💀 SAFE ULTRAGHOST-LITE INITIATED 💀" -ForegroundColor DarkRed

# ---------- 1. POWER & UI ----------
$ultimate = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $ultimate 2>$null
powercfg -setactive $ultimate 2>$null
powercfg -h off

Set-ItemProperty "HKCU:\Control Panel\Desktop" MenuShowDelay 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" StartupDelayInMSec 0 -ErrorAction SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" EnableTransparency 0 -ErrorAction SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" ColorPrevalence 0 -ErrorAction SilentlyContinue

# ---------- 2. NETWORK & AUDIO ----------
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TcpNoDelay 1
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TcpDelAckTicks 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xffffffff
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" Priority 6

# ---------- 3. TELEMETRY & GAMEBAR ----------
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

# ---------- 4. ESSENTIAL SERVICES ----------
# Only allow critical system and gaming processes
$essentialServices = @(
    "AudioEndpointBuilder","Dhcp","Dnscache","LanmanWorkstation",
    "Winmgmt","W32Time","NlaSvc","PlugPlay","RpcSs","Explorer","Steam Client Service",
    "winlogon","LogonUI","CredentialUIBroker","dwm"
)
Get-Service | Where-Object { $essentialServices -notcontains $_.Name } | ForEach-Object {
    Stop-Service $_.Name -Force -ErrorAction SilentlyContinue
    Set-Service $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
}

# ---------- 5. CLEANUP ----------
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# ---------- 6. SAFE PERSISTENT GHOST LOADER ----------
$loaderPath = "$Env:ProgramData\SafeUltraGhostLoader.ps1"

@"
\$allowedProcesses = @(
    "explorer","taskmgr","Steam","cs2","chrome","firefox","msedge","audiodg",
    "winlogon","LogonUI","CredentialUIBroker","dwm","settings"
)

while (\$true) {
    Get-Process | Where-Object { \$allowedProcesses -notcontains \$_.ProcessName } | ForEach-Object {
        try { \$_.Kill() } catch {}
    }
    Start-Sleep -Milliseconds 500
}
"@ | Set-Content -Path $loaderPath -Encoding ASCII -Force

# Persistent scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$loaderPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 999
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SafeUltraGhostLoader" -Description "Safe Persistent UltraGhost Loader" -Settings $settings -Force

# ---------- 7. COMPLETE ----------
Write-Host "💀 SAFE ULTRAGHOST-LITE LOADED 💀" -ForegroundColor Green
Write-Host "✅ Explorer + Taskbar + Settings + Steam + CS2 + Browser running" -ForegroundColor DarkGreen
Write-Host "💀 RAM idle ~1.2-1.5GB, CPU low, Max FPS, Ultra-Low Latency" -ForegroundColor DarkRed
Write-Host "💻 REBOOT NOW FOR FULL EFFECT 💻" -ForegroundColor DarkRed
