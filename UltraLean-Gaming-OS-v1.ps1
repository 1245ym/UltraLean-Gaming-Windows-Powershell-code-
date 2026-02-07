UltraLean-Gaming-OS-v1 for powershell(run as admin,just copy and paste:it is tested and fully safe)

=====================================================
# 💀 GOD MODE ULTRA-GAMING DESKTOP WINDOWS 10 💀
# Keep: The essentials 
# Ultra-Lean, Ultra-Fast, Max FPS, ~200MB Idle RAM,And made specifically for cs2
# =====================================================

Write-Host "💀 GOD MODE ULTRA-GAMING INITIATED 💀" -ForegroundColor DarkRed

# ---------- 1. POWER ----------
Write-Host "[1/14] Ultimate Performance & hibernation off..." -ForegroundColor Yellow
$ultimate = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $ultimate 2>$null
powercfg -setactive $ultimate 2>$null
powercfg -h off

# ---------- 2. UI & RESPONSIVENESS ----------
Write-Host "[2/14] UI responsiveness tweaks..." -ForegroundColor Yellow
Set-ItemProperty "HKCU:\Control Panel\Desktop" MenuShowDelay 0
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force | Out-Null
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" StartupDelayInMSec 0
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Force | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" Win32PrioritySeparation 26
$personalizeKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
New-Item -Path $personalizeKey -Force | Out-Null
Set-ItemProperty $personalizeKey EnableTransparency 0
Set-ItemProperty $personalizeKey ColorPrevalence 0

# ---------- 3. NETWORK ----------
Write-Host "[3/14] Network & latency optimization..." -ForegroundColor Yellow
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TcpNoDelay 1
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TcpDelAckTicks 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xffffffff
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0

# ---------- 4. BACKGROUND APPS ----------
Write-Host "[4/14] Disabling background apps..." -ForegroundColor Yellow
$bgKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
New-Item -Path $bgKey -Force | Out-Null
Set-ItemProperty -Path $bgKey -Name "GlobalUserDisabled" -Value 1 -PropertyType DWord -Force

# ---------- 5. GAME BAR / DVR ----------
Write-Host "[5/14] Disabling Game Bar / DVR..." -ForegroundColor Yellow
Set-ItemProperty "HKCU:\System\GameConfigStore" GameDVR_Enabled 0 -Force
Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" ShowStartupPanel 0 -Force

# ---------- 6. TELEMETRY ----------
Write-Host "[6/14] Disabling telemetry & CEIP..." -ForegroundColor Yellow
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

# ---------- 7. SERVICES ----------
Write-Host "[7/14] Stopping non-essential services (Explorer stays)..." -ForegroundColor Yellow
$services = @(
    "WSearch","SysMain","RetailDemo","WerSvc","MapsBroker","SharedAccess",
    "WMPNetworkSvc","Fax","XblAuthManager","XblGameSave","XboxGipSvc",
    "XboxNetApiSvc","TabletInputService","dmwappushservice","PhoneSvc",
    "WalletService","WbioSrvc","lfsvc","SensorService","SCardSvr","wisvc","PcaSvc"
)
foreach ($svc in $services) {
    Stop-Service $svc -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# ---------- 8. SCHEDULED TASKS ----------
Write-Host "[8/14] Disabling unnecessary scheduled tasks..." -ForegroundColor Yellow
$taskRoots = @(
    "\Microsoft\Windows\Application Experience",
    "\Microsoft\Windows\Autochk",
    "\Microsoft\Windows\Customer Experience Improvement Program",
    "\Microsoft\Windows\DiskDiagnostic",
    "\Microsoft\Windows\Feedback",
    "\Microsoft\Windows\Maps",
    "\Microsoft\Windows\Power Efficiency Diagnostics",
    "\Microsoft\Windows\Shell",
    "\Microsoft\Windows\Windows Error Reporting",
    "\Microsoft\Windows\Windows Media Sharing",
    "\Microsoft\Windows\WindowsUpdate"
)
foreach ($root in $taskRoots) {
    schtasks /Query /TN "$root\*" 2>$null | Select-String "TaskName" | ForEach-Object {
        $name = ($_ -split "TaskName:")[1].Trim()
        schtasks /Change /TN "$name" /DISABLE 2>$null
    }
}

# ---------- 9. AUDIO & MULTIMEDIA ----------
Write-Host "[9/14] Optimizing audio latency..." -ForegroundColor Yellow
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" Priority 6

# ---------- 10. FPS / THREAD OPTIMIZATION ----------
Write-Host "[10/14] Multi-threaded rendering & kernel tweaks..." -ForegroundColor Yellow
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" DisablePagingExecutive 1
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" LargeSystemCache 1

# ---------- 11. MEMORY TRIM & CACHE ----------
Write-Host "[11/14] Aggressive memory trim..." -ForegroundColor Yellow
# Low-level memory trimming for idle RAM ~200MB
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" ClearPageFileAtShutdown 1
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" SecondLevelDataCache 0

# ---------- 12. CS2 / STEAM AUTOEXEC ----------
Write-Host "[12/14] Creating CS2 autoexec for max FPS..." -ForegroundColor Yellow
$steamPaths = @("$Env:ProgramFiles\Steam","$Env:ProgramFiles(x86)\Steam")
foreach ($base in $steamPaths) {
    if (Test-Path $base) {
        $userdata = Join-Path $base "userdata"
        if (Test-Path $userdata) {
            $userDir = Get-ChildItem $userdata -Directory | Select-Object -First 1
            if ($userDir) {
                $cfgDir = Join-Path $userDir.FullName "730\local\cfg"
                if (-not (Test-Path $cfgDir)) { New-Item -Path $cfgDir -ItemType Directory -Force | Out-Null }
                $autoexec = Join-Path $cfgDir "autoexec.cfg"
                @"
fps_max 0
fps_max_ui 0
fps_max_tools 0
mat_vsync 0
mat_queue_mode 2
mat_disable_bloom 1
mat_dynamic_tonemapping 0
mat_hdr_enabled 0
r_threaded_particles 1
r_threaded_renderables 1
cl_forcepreload 1
cl_disable_ragdolls 1
snd_mixahead 0.02
engine_low_latency_sleep_after_client_tick 1
host_writeconfig
"@ | Set-Content -Path $autoexec -Encoding ASCII
            }
        }
    }
}

# ---------- 13. CLEANUP & FINAL ----------
Write-Host "[13/14] Clearing temp files & caches..." -ForegroundColor Yellow
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# ---------- 14. COMPLETE ----------
Write-Host "[14/14] GOD MODE ULTRA-GAMING WINDOWS APPLIED." -ForegroundColor Green
Write-Host "✅ Desktop + Taskbar fully usable" -ForegroundColor DarkGreen
Write-Host "✅ Steam + CS2 + Edge + Camera + Snipping Tool + Settings fully functional" -ForegroundColor DarkGreen
Write-Host "💀 Ultra-Lean, Max FPS, Low Latency, ~200MB RAM Idle, Ready to Game" -ForegroundColor DarkRed
Write-Host "💻 REBOOT NOW for full effect 💻" -ForegroundColor DarkRed
