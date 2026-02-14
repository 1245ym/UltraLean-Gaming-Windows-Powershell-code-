<#
.SYNOPSIS
    Yusuf Mullas WinUtil - Ultra Ultimate Windows Utility
.DESCRIPTION
    Inspired by Chris Titus Tech's WinUtil, but rebuilt:
    - Modern WPF GUI
    - Apps installer (winget)
    - Debloat (Safe, Recommended, Aggressive)
    - Tweaks (Explorer, Taskbar, Context Menu, Privacy, Gaming)
    - Backup
    - Latency analytics
    - Services manager
    - Tasks manager
    - Profiles (Gaming, Streaming, Work, Performance)
.NOTES
    Author: Yusuf Mullas
    License: MIT
#>

[CmdletBinding()]
param()

$global:WinUtil = @{
    Name    = "Yusuf Mullas WinUtil"
    Version = "2026.02.14"
    Repo    = "https://github.com/YusufMullas/YMs-Ultra-Lean-Optimization-Utility"
}

# ============================
# APP DESCRIPTIONS
# ============================
$global:AppDescriptions = @{
    "7-Zip" = "7-Zip - Lightweight file archiver."
    "Google Chrome" = "Chrome - Fast browser."
    "Visual Studio Code" = "VS Code - Code editor."
    "Discord" = "Discord - Chat and voice."
    "Steam" = "Steam - Game launcher."
}

# ============================
# DEBLOAT DESCRIPTIONS
# ============================
$global:DebloatDescriptions = @{
    "Safe" = "Safe Debloat: Removes obvious junk apps."
    "Recommended" = "Recommended Debloat: Removes more built-in apps."
    "Aggressive" = "Aggressive Debloat: Removes everything possible."
}

# ============================
# TWEAK DESCRIPTIONS
# ============================
$global:TweakDescriptions = @{
    "DarkMode" = "Forces Windows into dark mode."
    "DisableAnimations" = "Disables UI animations."
    "HighPerfPower" = "Enables High Performance power plan."
}

# ============================
# LATENCY DESCRIPTIONS
# ============================
$global:LatencyDescriptions = @{
    "Latency" = "Latency (ping) explanation."
    "Jitter" = "Jitter explanation."
    "PacketLoss" = "Packet loss explanation."
    "Rating" = "Connection rating explanation."
}
# ============================
# APP MAP (BIG CATALOG)
# ============================
$global:AppMap = @{

    # Browsers
    "Google Chrome"      = "Google.Chrome"
    "Microsoft Edge"     = "Microsoft.Edge"
    "Brave"              = "Brave.Brave"
    "Mozilla Firefox"    = "Mozilla.Firefox"

    # Dev
    "Visual Studio Code" = "Microsoft.VisualStudioCode"
    "Visual Studio 2022 Community" = "Microsoft.VisualStudio.2022.Community"
    "Git"                = "Git.Git"
    "Node.js LTS"        = "OpenJS.NodeJS.LTS"
    "Python 3"           = "Python.Python.3"

    # Gaming
    "Steam"              = "Valve.Steam"
    "Epic Games Launcher"= "EpicGames.EpicGamesLauncher"
    "GOG Galaxy"         = "GOG.Galaxy"
    "Discord"            = "Discord.Discord"

    # Media
    "VLC"                = "VideoLAN.VLC"
    "Spotify"            = "Spotify.Spotify"
    "OBS Studio"         = "OBSProject.OBSStudio"
    "MPV"                = "mpv.net.mpv.net"

    # Tools
    "7-Zip"              = "7zip.7zip"
    "WinRAR"             = "RARLab.WinRAR"
    "Notepad++"          = "Notepad++.Notepad++"
    "Everything Search"  = "voidtools.Everything"
    "HWInfo"             = "REALiX.HWiNFO"
    "CPU-Z"              = "CPUID.CPU-Z"
    "GPU-Z"              = "TechPowerUp.GPU-Z"
}

# ============================
# SERVICE GROUPS
# ============================
$global:ServiceItems = @(
    [pscustomobject]@{
        Key="Xbox"; DisplayName="Disable Xbox Services";
        Description="Disables Xbox services."; Services=@("XblAuthManager","XblGameSave","XboxGipSvc","XboxNetApiSvc")
    }
    [pscustomobject]@{
        Key="Search"; DisplayName="Disable Windows Search";
        Description="Disables indexing."; Services=@("WSearch")
    }
    [pscustomobject]@{
        Key="Updates"; DisplayName="Disable Windows Update";
        Description="Stops Windows Update."; Services=@("wuauserv","UsoSvc","BITS")
    }
    [pscustomobject]@{
        Key="OneDrive"; DisplayName="Disable OneDrive";
        Description="Stops OneDrive sync."; Services=@("OneSyncSvc","OneDrive")
    }
    [pscustomobject]@{
        Key="Bluetooth"; DisplayName="Disable Bluetooth";
        Description="Stops Bluetooth services."; Services=@("bthserv")
    }
)

# ============================
# TASK GROUPS
# ============================
$global:TaskItems = @(
    [pscustomobject]@{
        Key="DefenderTasks"; DisplayName="Disable Defender Tasks";
        Description="Stops Defender scheduled tasks.";
        TaskPaths=@(
            "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
            "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
            "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
            "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
        )
    }
    [pscustomobject]@{
        Key="UpdateTasks"; DisplayName="Disable Update Tasks";
        Description="Stops Windows Update tasks.";
        TaskPaths=@(
            "\Microsoft\Windows\WindowsUpdate\Scheduled Start",
            "\Microsoft\Windows\WindowsUpdate\Automatic App Update"
        )
    }
)
# ============================
# XAML GUI (FULL WINDOW)
# ============================

Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Yusuf Mullas WinUtil"
        Height="650" Width="1100"
        WindowStartupLocation="CenterScreen"
        Background="#1E1E1E" Foreground="#F0F0F0"
        FontFamily="Segoe UI">

    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="6"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Background" Value="#3A3A3A"/>
            <Setter Property="Foreground" Value="#F0F0F0"/>
            <Setter Property="BorderBrush" Value="#5A5A5A"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Margin" Value="6"/>
            <Setter Property="Background" Value="#2A2A2A"/>
            <Setter Property="Foreground" Value="#F0F0F0"/>
            <Setter Property="BorderBrush" Value="#555555"/>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="4,4,4,4"/>
        </Style>

        <Style TargetType="TabItem">
            <Setter Property="Margin" Value="0,0,4,0"/>
        </Style>
    </Window.Resources>

    <DockPanel>

        <!-- TOP BAR -->
        <Border DockPanel.Dock="Top" Background="#252526" Height="48">
            <Grid Margin="10,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="Yusuf Mullas WinUtil"
                               FontSize="20"
                               FontWeight="Bold"
                               Margin="4,0,10,0"/>
                    <TextBlock Text="Ultra Ultimate Edition"
                               FontSize="12"
                               Foreground="#AAAAAA"
                               VerticalAlignment="Center"/>
                </StackPanel>

                <TextBlock Grid.Column="1"
                           Text="{Binding VersionText}"
                           VerticalAlignment="Center"
                           Foreground="#AAAAAA"/>
            </Grid>
        </Border>

        <!-- MAIN CONTENT -->
        <Grid Margin="8">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="3*"/>
                <ColumnDefinition Width="2*"/>
            </Grid.ColumnDefinitions>

            <!-- LEFT SIDE: TABS -->
            <TabControl Grid.Column="0" Margin="0,0,8,0">

                <!-- ============================
                     APPS TAB
                ============================ -->
                <TabItem Header="Apps">
                    <Grid Margin="10">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <TextBlock Text="App Installer"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <ListBox x:Name="AppsList"
                                 Grid.Row="1"
                                 Background="#2A2A2A"
                                 BorderBrush="#444444">

                            <ListBoxItem Content="--- Browsers ---" IsEnabled="False"/>
                            <ListBoxItem Content="Google Chrome"/>
                            <ListBoxItem Content="Microsoft Edge"/>
                            <ListBoxItem Content="Brave"/>
                            <ListBoxItem Content="Mozilla Firefox"/>

                            <ListBoxItem Content="--- Dev ---" IsEnabled="False"/>
                            <ListBoxItem Content="Visual Studio Code"/>
                            <ListBoxItem Content="Visual Studio 2022 Community"/>
                            <ListBoxItem Content="Git"/>
                            <ListBoxItem Content="Node.js LTS"/>
                            <ListBoxItem Content="Python 3"/>

                            <ListBoxItem Content="--- Gaming ---" IsEnabled="False"/>
                            <ListBoxItem Content="Steam"/>
                            <ListBoxItem Content="Epic Games Launcher"/>
                            <ListBoxItem Content="GOG Galaxy"/>
                            <ListBoxItem Content="Discord"/>

                            <ListBoxItem Content="--- Media ---" IsEnabled="False"/>
                            <ListBoxItem Content="VLC"/>
                            <ListBoxItem Content="Spotify"/>
                            <ListBoxItem Content="OBS Studio"/>
                            <ListBoxItem Content="MPV"/>

                            <ListBoxItem Content="--- Tools ---" IsEnabled="False"/>
                            <ListBoxItem Content="7-Zip"/>
                            <ListBoxItem Content="WinRAR"/>
                            <ListBoxItem Content="Notepad++"/>
                            <ListBoxItem Content="Everything Search"/>
                            <ListBoxItem Content="HWInfo"/>
                            <ListBoxItem Content="CPU-Z"/>
                            <ListBoxItem Content="GPU-Z"/>

                        </ListBox>

                        <StackPanel Grid.Row="2"
                                    Orientation="Horizontal"
                                    HorizontalAlignment="Right"
                                    Margin="0,8,0,0">
                            <Button x:Name="InstallSelectedAppsBtn" Content="Install Selected"/>
                            <Button x:Name="RefreshAppsBtn" Content="Refresh List" Margin="6,0,0,0"/>
                        </StackPanel>
                    </Grid>
                </TabItem>

                <!-- ============================
                     DEBLOAT TAB
                ============================ -->
                <TabItem Header="Debloat">
                    <StackPanel Margin="10">
                        <TextBlock Text="Debloat Options"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <TextBlock Text="Choose what to remove or disable."
                                   TextWrapping="Wrap"
                                   Foreground="#BBBBBB"
                                   Margin="0,0,0,10"/>

                        <CheckBox x:Name="RemoveBloatwareChk"
                                  Content="Aggressive Debloat (Safe + Recommended + Extra)"/>
                        <CheckBox x:Name="DisableTelemetryChk"
                                  Content="Disable Telemetry"/>
                        <CheckBox x:Name="DisableSuggestionsChk"
                                  Content="Disable Suggestions"/>

                        <StackPanel Orientation="Horizontal"
                                    HorizontalAlignment="Right"
                                    Margin="0,20,0,0">
                            <Button x:Name="RunDebloatBtn" Content="Run Debloat"/>
                        </StackPanel>
                    </StackPanel>
                </TabItem>

                <!-- ============================
                     TWEAKS TAB
                ============================ -->
                <TabItem Header="Tweaks">
                    <StackPanel Margin="10">
                        <TextBlock Text="System Tweaks"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <CheckBox x:Name="EnableDarkModeChk"
                                  Content="Force Dark Mode"/>
                        <CheckBox x:Name="DisableAnimationsChk"
                                  Content="Disable UI Animations"/>
                        <CheckBox x:Name="SetHighPerfPowerChk"
                                  Content="High Performance Power Plan"/>

                        <StackPanel Orientation="Horizontal"
                                    HorizontalAlignment="Right"
                                    Margin="0,20,0,0">
                            <Button x:Name="ApplyTweaksBtn" Content="Apply Tweaks"/>
                        </StackPanel>
                    </StackPanel>
                </TabItem>

                <!-- ============================
                     BACKUP TAB
                ============================ -->
                <TabItem Header="Backup">
                    <StackPanel Margin="10">
                        <TextBlock Text="Backup & Restore"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <StackPanel Orientation="Horizontal" Margin="0,4,0,0">
                            <Button x:Name="BackupConfigBtn" Content="Backup Config"/>
                            <Button x:Name="RestoreConfigBtn" Content="Restore Config" Margin="6,0,0,0"/>
                        </StackPanel>

                        <TextBlock x:Name="BackupStatusTxt"
                                   Margin="4,10,0,0"
                                   Foreground="#AAAAAA"/>
                    </StackPanel>
                </TabItem>

                <!-- ============================
                     LATENCY TAB
                ============================ -->
                <TabItem Header="Latency">
                    <Grid Margin="10">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <TextBlock Text="Latency & Network"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <StackPanel Grid.Row="1"
                                    Orientation="Horizontal"
                                    VerticalAlignment="Top"
                                    Margin="0,4,0,0">
                            <TextBlock Text="Target Host:"
                                       VerticalAlignment="Center"
                                       Margin="0,0,6,0"/>
                            <TextBox x:Name="LatencyHostTxt"
                                     Width="220"
                                     Text="8.8.8.8"/>
                            <Button x:Name="TestLatencyBtn"
                                    Content="Test Latency"
                                    Margin="8,0,0,0"/>
                        </StackPanel>

                        <TextBox x:Name="LatencyOutputTxt"
                                 Grid.Row="2"
                                 Margin="0,10,0,0"
                                 IsReadOnly="True"
                                 TextWrapping="Wrap"
                                 VerticalScrollBarVisibility="Auto"
                                 Background="#202020"
                                 BorderBrush="#444444"/>
                    </Grid>
                </TabItem>

                <!-- ============================
                     SERVICES TAB
                ============================ -->
                <TabItem Header="Services">
                    <Grid Margin="10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="2*"/>
                            <ColumnDefinition Width="3*"/>
                        </Grid.ColumnDefinitions>

                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <TextBlock Text="Services (Aggressive Mode)"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <ListBox x:Name="ServicesList"
                                 Grid.Row="1"
                                 Grid.Column="0"
                                 Background="#2A2A2A"
                                 BorderBrush="#444444"
                                 DisplayMemberPath="DisplayName"
                                 SelectedIndex="0"/>

                        <TextBox x:Name="ServiceDescBox"
                                 Grid.Row="1"
                                 Grid.Column="1"
                                 Margin="8,0,0,0"
                                 IsReadOnly="True"
                                 TextWrapping="Wrap"
                                 VerticalScrollBarVisibility="Auto"
                                 Background="#202020"
                                 BorderBrush="#444444"/>

                        <StackPanel Grid.Row="2"
                                    Grid.ColumnSpan="2"
                                    Orientation="Horizontal"
                                    HorizontalAlignment="Right"
                                    Margin="0,8,0,0">
                            <Button x:Name="ApplyServicesBtn" Content="Apply Selected Service Tweaks"/>
                        </StackPanel>
                    </Grid>
                </TabItem>

                <!-- ============================
                     TASKS TAB
                ============================ -->
                <TabItem Header="Tasks">
                    <Grid Margin="10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="2*"/>
                            <ColumnDefinition Width="3*"/>
                        </Grid.ColumnDefinitions>

                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <TextBlock Text="Scheduled Tasks (Aggressive Mode)"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <ListBox x:Name="TasksList"
                                 Grid.Row="1"
                                 Grid.Column="0"
                                 Background="#2A2A2A"
                                 BorderBrush="#444444"
                                 DisplayMemberPath="DisplayName"
                                 SelectedIndex="0"/>

                        <TextBox x:Name="TaskDescBox"
                                 Grid.Row="1"
                                 Grid.Column="1"
                                 Margin="8,0,0,0"
                                 IsReadOnly="True"
                                 TextWrapping="Wrap"
                                 VerticalScrollBarVisibility="Auto"
                                 Background="#202020"
                                 BorderBrush="#444444"/>

                        <StackPanel Grid.Row="2"
                                    Grid.ColumnSpan="2"
                                    Orientation="Horizontal"
                                    HorizontalAlignment="Right"
                                    Margin="0,8,0,0">
                            <Button x:Name="ApplyTasksBtn" Content="Apply Selected Task Tweaks"/>
                        </StackPanel>
                    </Grid>
                </TabItem>

                <!-- ============================
                     PROFILES TAB
                ============================ -->
                <TabItem Header="Profiles">
                    <StackPanel Margin="10">
                        <TextBlock Text="Profiles"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Margin="0,0,0,8"/>

                        <StackPanel Orientation="Vertical" Margin="0,4,0,0">
                            <Button x:Name="GamingProfileBtn" Content="Apply Gaming Mode" Margin="0,0,0,4"/>
                            <Button x:Name="StreamingProfileBtn" Content="Apply Streaming Mode" Margin="0,0,0,4"/>
                            <Button x:Name="WorkProfileBtn" Content="Apply Work Mode" Margin="0,0,0,4"/>
                            <Button x:Name="PerformanceProfileBtn" Content="Apply Performance Mode" Margin="0,10,0,0"/>
                        </StackPanel>
                    </StackPanel>
                </TabItem>

            </TabControl>

            <!-- RIGHT SIDE: INFO PANEL -->
            <Border Grid.Column="1"
                    Background="#202020"
                    BorderBrush="#444444"
                    BorderThickness="1"
                    CornerRadius="4"
                    Padding="8">
                <StackPanel>
                    <TextBlock Text="Console / Info"
                               FontSize="16"
                               FontWeight="SemiBold"
                               Margin="0,0,0,6"/>
                    <TextBlock Text="Run this script from PowerShell to see detailed logs and descriptions for every action."
                               TextWrapping="Wrap"
                               Foreground="#BBBBBB"/>
                </StackPanel>
            </Border>

        </Grid>
    </DockPanel>
</Window>
"@
# ============================
# LOAD XAML + BIND CONTROLS
# ============================

[xml]$xamlXml = $xaml
$reader = New-Object System.Xml.XmlNodeReader $xamlXml
$window = [Windows.Markup.XamlReader]::Load($reader)

$window.DataContext = [pscustomobject]@{
    VersionText = "v$($WinUtil.Version)"
}

# Controls
$AppsList            = $window.FindName("AppsList")
$InstallSelectedApps = $window.FindName("InstallSelectedAppsBtn")
$RefreshAppsBtn      = $window.FindName("RefreshAppsBtn")

$RemoveBloatwareChk    = $window.FindName("RemoveBloatwareChk")
$DisableTelemetryChk   = $window.FindName("DisableTelemetryChk")
$DisableSuggestionsChk = $window.FindName("DisableSuggestionsChk")
$RunDebloatBtn         = $window.FindName("RunDebloatBtn")

$EnableDarkModeChk     = $window.FindName("EnableDarkModeChk")
$DisableAnimationsChk  = $window.FindName("DisableAnimationsChk")
$SetHighPerfPowerChk   = $window.FindName("SetHighPerfPowerChk")
$ApplyTweaksBtn        = $window.FindName("ApplyTweaksBtn")

$BackupConfigBtn       = $window.FindName("BackupConfigBtn")
$RestoreConfigBtn      = $window.FindName("RestoreConfigBtn")
$BackupStatusTxt       = $window.FindName("BackupStatusTxt")

$LatencyHostTxt        = $window.FindName("LatencyHostTxt")
$TestLatencyBtn        = $window.FindName("TestLatencyBtn")
$LatencyOutputTxt      = $window.FindName("LatencyOutputTxt")

$ServicesList          = $window.FindName("ServicesList")
$ServiceDescBox        = $window.FindName("ServiceDescBox")
$ApplyServicesBtn      = $window.FindName("ApplyServicesBtn")

$TasksList             = $window.FindName("TasksList")
$TaskDescBox           = $window.FindName("TaskDescBox")
$ApplyTasksBtn         = $window.FindName("ApplyTasksBtn")

$GamingProfileBtn      = $window.FindName("GamingProfileBtn")
$StreamingProfileBtn   = $window.FindName("StreamingProfileBtn")
$WorkProfileBtn        = $window.FindName("WorkProfileBtn")
$PerformanceProfileBtn = $window.FindName("PerformanceProfileBtn")

# ============================
# APP INSTALLER LOGIC
# ============================

function Install-SelectedApps {
    param(
        [System.Windows.Controls.ListBox]$ListBox
    )

    $selected = $ListBox.SelectedItems |
        ForEach-Object { $_.Content } |
        Where-Object { $_ -notlike "---*" }

    if (-not $selected) {
        [System.Windows.MessageBox]::Show("No apps selected.", "Yusuf WinUtil")
        return
    }

    foreach ($app in $selected) {
        $name = [string]$app

        if ($AppDescriptions.ContainsKey($name)) {
            Write-Host ""
            Write-Host "=== $name ===" -ForegroundColor Green
            Write-Host $AppDescriptions[$name]
        }

        if (-not $AppMap.ContainsKey($name)) {
            Write-Host "No winget ID mapped for $name" -ForegroundColor Yellow
            continue
        }

        $id = $AppMap[$name]
        Write-Host "Installing $name ($id) via winget..." -ForegroundColor Cyan
        Start-Process winget -ArgumentList "install --id `"$id`" -e --source winget --accept-source-agreements --accept-package-agreements" -NoNewWindow
    }

    [System.Windows.MessageBox]::Show("Install commands issued. Check console for details.", "Yusuf WinUtil")
}
# ============================
# DEBLOAT HELPERS
# ============================

function Remove-Bloat-Safe {
    Write-Host "[Debloat: Safe] Removing basic junk..." -ForegroundColor Cyan

    $patterns = @(
        "*Microsoft.GetHelp*",
        "*Microsoft.Getstarted*",
        "*Microsoft.Microsoft3DViewer*",
        "*Microsoft.MicrosoftSolitaireCollection*",
        "*Microsoft.SkypeApp*"
    )

    foreach ($p in $patterns) {
        Get-AppxPackage -Name $p -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online |
            Where-Object DisplayName -Like $p |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
}

function Remove-Bloat-Recommended {
    Write-Host "[Debloat: Recommended] Removing more built-in apps..." -ForegroundColor Cyan

    Remove-Bloat-Safe

    $patterns = @(
        "*XboxApp*",
        "*XboxGamingOverlay*",
        "*Microsoft.Xbox*",
        "*Microsoft.ZuneMusic*",
        "*Microsoft.ZuneVideo*",
        "*Microsoft.MicrosoftOfficeHub*",
        "*Microsoft.People*",
        "*Microsoft.MicrosoftStickyNotes*"
    )

    foreach ($p in $patterns) {
        Get-AppxPackage -Name $p -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online |
            Where-Object DisplayName -Like $p |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
}

function Remove-Bloat-Aggressive {
    Write-Host "[Debloat: Aggressive] Removing EVERYTHING possible..." -ForegroundColor Red

    Remove-Bloat-Recommended

    $patterns = @(
        "*Microsoft.BingNews*",
        "*Microsoft.BingWeather*",
        "*Microsoft.MicrosoftNews*",
        "*Microsoft.Todos*",
        "*Microsoft.YourPhone*",
        "*Microsoft.WindowsMaps*",
        "*Microsoft.WindowsFeedbackHub*"
    )

    foreach ($p in $patterns) {
        Get-AppxPackage -Name $p -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online |
            Where-Object DisplayName -Like $p |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
}

# ============================
# TELEMETRY DISABLE
# ============================

function Disable-Telemetry {
    Write-Host "[Debloat: Disable Telemetry]" -ForegroundColor Yellow

    $services = @(
        "DiagTrack",
        "dmwappushservice"
    )

    foreach ($svc in $services) {
        Get-Service -Name $svc -ErrorAction SilentlyContinue | ForEach-Object {
            Stop-Service $_.Name -Force -ErrorAction SilentlyContinue
            Set-Service $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
        -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

# ============================
# SUGGESTIONS DISABLE
# ============================

function Disable-Suggestions {
    Write-Host "[Debloat: Disable Suggestions]" -ForegroundColor Yellow

    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    )

    foreach ($p in $paths) {
        New-Item -Path $p -Force | Out-Null
    }

    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        "SystemPaneSuggestionsEnabled" 0 -Type DWord -ErrorAction SilentlyContinue

    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
        "DisableConsumerFeatures" 1 -Type DWord -ErrorAction SilentlyContinue
}

# ============================
# RUN DEBLOAT (AGGRESSIVE MODE)
# ============================

function Run-Debloat {
    param(
        [bool]$RemoveBloatware,
        [bool]$DisableTelemetry,
        [bool]$DisableSuggestions
    )

    if ($RemoveBloatware) {
        Write-Host ""
        Write-Host "=== AGGRESSIVE DEBLOAT ===" -ForegroundColor Red
        Write-Host $DebloatDescriptions["Aggressive"]
        Remove-Bloat-Aggressive
    }

    if ($DisableTelemetry) {
        Write-Host ""
        Write-Host "=== DISABLE TELEMETRY ===" -ForegroundColor Yellow
        Disable-Telemetry
    }

    if ($DisableSuggestions) {
        Write-Host ""
        Write-Host "=== DISABLE SUGGESTIONS ===" -ForegroundColor Yellow
        Disable-Suggestions
    }

    [System.Windows.MessageBox]::Show("Aggressive debloat completed. Reboot strongly recommended.", "Yusuf WinUtil")
}
# ============================
# TWEAKS: CORE
# ============================

function Set-DarkMode {
    Write-Host ""
    Write-Host "[Tweaks: Dark Mode]" -ForegroundColor Cyan

    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    New-Item -Path $path -Force | Out-Null

    Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $path -Name "SystemUsesLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

function Disable-UIAnimations {
    Write-Host ""
    Write-Host "[Tweaks: Disable Animations]" -ForegroundColor Cyan

    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Type DWord -Value 2 -ErrorAction SilentlyContinue

    $advPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $advPath -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
}

function Set-HighPerformancePlan {
    Write-Host ""
    Write-Host "[Tweaks: High Performance Power Plan]" -ForegroundColor Cyan
    powercfg -setactive SCHEME_MIN
}

# ============================
# TWEAKS: EXPLORER / TASKBAR / CONTEXT / PRIVACY / GAMING
# ============================

function Tweak-Explorer {
    Write-Host ""
    Write-Host "[Tweaks: Explorer]" -ForegroundColor Cyan

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-Item -Path $path -Force | Out-Null

    Set-ItemProperty -Path $path -Name "Hidden" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $path -Name "HideFileExt" -Type DWord -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $path -Name "ShowSuperHidden" -Type DWord -Value 1 -ErrorAction SilentlyContinue
}

function Tweak-Taskbar {
    Write-Host ""
    Write-Host "[Tweaks: Taskbar]" -ForegroundColor Cyan

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-Item -Path $path -Force | Out-Null

    Set-ItemProperty -Path $path -Name "TaskbarSmallIcons" -Type DWord -Value 1 -ErrorAction SilentlyContinue
}

function Tweak-ContextMenu {
    Write-Host ""
    Write-Host "[Tweaks: Context Menu]" -ForegroundColor Cyan

    $path = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    New-Item -Path $path -Force | Out-Null
    Set-ItemProperty -Path $path -Name "(default)" -Value "" -ErrorAction SilentlyContinue
}

function Tweak-Privacy {
    Write-Host ""
    Write-Host "[Tweaks: Privacy]" -ForegroundColor Cyan

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" `
        -Name "DisabledByGroupPolicy" -Type DWord -Value 1 -ErrorAction SilentlyContinue
}

function Tweak-Gaming {
    Write-Host ""
    Write-Host "[Tweaks: Gaming]" -ForegroundColor Cyan

    New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWord -Value 2 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

# ============================
# APPLY TWEAKS (AGGRESSIVE)
# ============================

function Apply-Tweaks {
    param(
        [bool]$DarkMode,
        [bool]$DisableAnimations,
        [bool]$HighPerfPower
    )

    if ($DarkMode)         { Set-DarkMode }
    if ($DisableAnimations){ Disable-UIAnimations }
    if ($HighPerfPower)    { Set-HighPerformancePlan }

    Tweak-Explorer
    Tweak-Taskbar
    Tweak-ContextMenu
    Tweak-Privacy
    Tweak-Gaming

    [System.Windows.MessageBox]::Show("Aggressive tweaks applied. Some require sign-out or reboot.", "Yusuf WinUtil")
}
# ============================
# BACKUP / RESTORE
# ============================

function Backup-Config {
    param(
        [System.Windows.Controls.TextBlock]$StatusControl
    )

    $path = Join-Path $env:USERPROFILE "yusuf-winutil-backup.json"
    $config = @{
        Timestamp = (Get-Date)
        Version   = $WinUtil.Version
    } | ConvertTo-Json -Depth 5

    $config | Set-Content -Path $path -Encoding UTF8
    $StatusControl.Text = "Backup saved to $path"
}

function Restore-Config {
    param(
        [System.Windows.Controls.TextBlock]$StatusControl
    )

    $path = Join-Path $env:USERPROFILE "yusuf-winutil-backup.json"
    if (-not (Test-Path $path)) {
        $StatusControl.Text = "No backup found at $path"
        return
    }

    $json = Get-Content -Path $path -Raw | ConvertFrom-Json
    $StatusControl.Text = "Backup loaded from $path (apply logic not yet implemented)"
}

# ============================
# LATENCY / NETWORK
# ============================

function Test-Latency {
    param(
        [string]$Host,
        [System.Windows.Controls.TextBox]$OutputControl
    )

    if ([string]::IsNullOrWhiteSpace($Host)) {
        $Host = "8.8.8.8"
    }

    $OutputControl.Clear()
    $OutputControl.AppendText("Pinging $Host ...`r`n`r`n")

    try {
        $count = 10
        $results = Test-Connection -ComputerName $Host -Count $count -ErrorAction Stop

        $rtts = $results | Select-Object -ExpandProperty ResponseTime
        $avg  = ($rtts | Measure-Object -Average).Average
        $min  = ($rtts | Measure-Object -Minimum).Minimum
        $max  = ($rtts | Measure-Object -Maximum).Maximum
        $jitter = $max - $min

        $received = $results.Count
        $loss = (($count - $received) / $count) * 100

        foreach ($r in $results) {
            $OutputControl.AppendText("Reply from {0}: time={1}ms`r`n" -f $r.Address, $r.ResponseTime)
        }

        $OutputControl.AppendText("`r`n--- Stats ---`r`n")
        $OutputControl.AppendText("Packets: Sent = $count, Received = $received, Lost = {0} ({1:N1}% loss)`r`n" -f ($count - $received), $loss)
        $OutputControl.AppendText("Latency: Avg = {0:N1} ms, Min = {1:N1} ms, Max = {2:N1} ms`r`n" -f $avg, $min, $max)
        $OutputControl.AppendText("Jitter: {0:N1} ms`r`n`r`n" -f $jitter)

        $rating = if ($loss -ge 5 -or $avg -ge 120 -or $jitter -ge 40) {
            "Bad for gaming / unstable"
        }
        elseif ($avg -le 40 -and $jitter -le 15 -and $loss -lt 1) {
            "Excellent - great for gaming and streaming"
        }
        elseif ($avg -le 80 -and $jitter -le 25 -and $loss -lt 3) {
            "Good - fine for most online games"
        }
        else {
            "Okay - usable, but not ideal for competitive gaming"
        }

        $OutputControl.AppendText("Rating: $rating`r`n`r`n")

        $OutputControl.AppendText("--- Explanations ---`r`n")
        $OutputControl.AppendText($LatencyDescriptions["Latency"] + "`r`n`r`n")
        $OutputControl.AppendText($LatencyDescriptions["Jitter"] + "`r`n`r`n")
        $OutputControl.AppendText($LatencyDescriptions["PacketLoss"] + "`r`n`r`n")
        $OutputControl.AppendText($LatencyDescriptions["Rating"])
    }
    catch {
        $OutputControl.AppendText("Error testing latency: $($_.Exception.Message)")
    }
}

# ============================
# SERVICES / TASKS ENGINE
# ============================

function Set-ServicesState {
    param(
        [string[]]$ServiceNames,
        [string]$State
    )

    foreach ($svcName in $ServiceNames) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if (-not $svc) {
            Write-Host "Service not found: $svcName" -ForegroundColor Yellow
            continue
        }

        if ($State -eq "Disable") {
            Write-Host "Disabling service: $svcName" -ForegroundColor Cyan
            try {
                Stop-Service $svcName -Force -ErrorAction SilentlyContinue
                Set-Service $svcName -StartupType Disabled -ErrorAction SilentlyContinue
            } catch {}
        }
        elseif ($State -eq "Enable") {
            Write-Host "Enabling service: $svcName" -ForegroundColor Cyan
            try {
                Set-Service $svcName -StartupType Automatic -ErrorAction SilentlyContinue
                Start-Service $svcName -ErrorAction SilentlyContinue
            } catch {}
        }
    }
}

function Apply-ServiceItem {
    param(
        [pscustomobject]$Item,
        [string]$State
    )

    Write-Host ""
    Write-Host "[Service Group: $($Item.DisplayName)]" -ForegroundColor Magenta
    Write-Host $Item.Description
    Set-ServicesState -ServiceNames $Item.Services -State $State
}

function Set-TasksState {
    param(
        [string[]]$TaskPaths,
        [string]$State
    )

    foreach ($path in $TaskPaths) {
        try {
            if ($path.EndsWith("*")) {
                $folderPath = Split-Path $path
                $tasks = Get-ScheduledTask -TaskPath $folderPath -ErrorAction SilentlyContinue
                if ($tasks) {
                    $tasks | ForEach-Object {
                        if ($State -eq "Disable") {
                            Write-Host "Disabling task: $($_.TaskName)" -ForegroundColor Cyan
                            Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue
                        } else {
                            Write-Host "Enabling task: $($_.TaskName)" -ForegroundColor Cyan
                            Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
            else {
                $task = Get-ScheduledTask -TaskPath (Split-Path $path) -TaskName (Split-Path $path -Leaf) -ErrorAction SilentlyContinue
                if ($task) {
                    if ($State -eq "Disable") {
                        Write-Host "Disabling task: $path" -ForegroundColor Cyan
                        Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
                    } else {
                        Write-Host "Enabling task: $path" -ForegroundColor Cyan
                        Enable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
                    }
                } else {
                    Write-Host "Task not found: $path" -ForegroundColor Yellow
                }
            }
        } catch {}
    }
}

function Apply-TaskItem {
    param(
        [pscustomobject]$Item,
        [string]$State
    )

    Write-Host ""
    Write-Host "[Task Group: $($Item.DisplayName)]" -ForegroundColor Magenta
    Write-Host $Item.Description
    Set-TasksState -TaskPaths $Item.TaskPaths -State $State
}
# ============================
# PROFILES
# ============================

function Apply-GamingProfile {
    Write-Host ""
    Write-Host "=== GAMING PROFILE ===" -ForegroundColor Green

    Apply-Tweaks -DarkMode $true -DisableAnimations $true -HighPerfPower $true

    $gamingServices = $ServiceItems | Where-Object { $_.Key -in @("Xbox","Search","Updates","OneDrive","Bluetooth") }
    foreach ($item in $gamingServices) {
        Apply-ServiceItem -Item $item -State "Disable"
    }

    $gamingTasks = $TaskItems | Where-Object { $_.Key -in @("DefenderTasks","UpdateTasks") }
    foreach ($item in $gamingTasks) {
        Apply-TaskItem -Item $item -State "Disable"
    }

    [System.Windows.MessageBox]::Show("Gaming Mode applied.", "Yusuf WinUtil")
}

function Apply-StreamingProfile {
    Write-Host ""
    Write-Host "=== STREAMING PROFILE ===" -ForegroundColor Green

    Apply-Tweaks -DarkMode $true -DisableAnimations $true -HighPerfPower $true

    $streamServices = $ServiceItems | Where-Object { $_.Key -in @("Search","Updates","OneDrive") }
    foreach ($item in $streamServices) {
        Apply-ServiceItem -Item $item -State "Disable"
    }

    $streamTasks = $TaskItems | Where-Object { $_.Key -in @("DefenderTasks","UpdateTasks") }
    foreach ($item in $streamTasks) {
        Apply-TaskItem -Item $item -State "Disable"
    }

    [System.Windows.MessageBox]::Show("Streaming Mode applied.", "Yusuf WinUtil")
}

function Apply-WorkProfile {
    Write-Host ""
    Write-Host "=== WORK PROFILE ===" -ForegroundColor Green

    Apply-Tweaks -DarkMode $true -DisableAnimations $false -HighPerfPower $true

    $workServices = $ServiceItems | Where-Object { $_.Key -in @("Search","OneDrive") }
    foreach ($item in $workServices) {
        Apply-ServiceItem -Item $item -State "Disable"
    }

    [System.Windows.MessageBox]::Show("Work Mode applied.", "Yusuf WinUtil")
}

function Apply-PerformanceProfile {
    Write-Host ""
    Write-Host "=== PERFORMANCE PROFILE ===" -ForegroundColor Green

    Apply-Tweaks -DarkMode $true -DisableAnimations $true -HighPerfPower $true

    foreach ($item in $ServiceItems) {
        Apply-ServiceItem -Item $item -State "Disable"
    }
    foreach ($item in $TaskItems) {
        Apply-TaskItem -Item $item -State "Disable"
    }

    [System.Windows.MessageBox]::Show("Performance Mode applied (very aggressive).", "Yusuf WinUtil")
}

# ============================
# POPULATE SERVICES / TASKS LISTS
# ============================

$ServicesList.ItemsSource = $ServiceItems
if ($ServiceItems.Count -gt 0) {
    $ServicesList.SelectedIndex = 0
    $ServiceDescBox.Text = $ServiceItems[0].Description
}

$TasksList.ItemsSource = $TaskItems
if ($TaskItems.Count -gt 0) {
    $TasksList.SelectedIndex = 0
    $TaskDescBox.Text = $TaskItems[0].Description
}

# ============================
# EVENT WIRING
# ============================

$InstallSelectedApps.Add_Click({
    Install-SelectedApps -ListBox $AppsList
})

$RefreshAppsBtn.Add_Click({
    [System.Windows.MessageBox]::Show("Static list in this version. Extend AppMap to add more.", "Yusuf WinUtil")
})

$RunDebloatBtn.Add_Click({
    Run-Debloat -RemoveBloatware $RemoveBloatwareChk.IsChecked `
                -DisableTelemetry $DisableTelemetryChk.IsChecked `
                -DisableSuggestions $DisableSuggestionsChk.IsChecked
})

$ApplyTweaksBtn.Add_Click({
    Apply-Tweaks -DarkMode $EnableDarkModeChk.IsChecked `
                 -DisableAnimations $DisableAnimationsChk.IsChecked `
                 -HighPerfPower $SetHighPerfPowerChk.IsChecked
})

$BackupConfigBtn.Add_Click({
    Backup-Config -StatusControl $BackupStatusTxt
})

$RestoreConfigBtn.Add_Click({
    Restore-Config -StatusControl $BackupStatusTxt
})

$TestLatencyBtn.Add_Click({
    Test-Latency -Host $LatencyHostTxt.Text -OutputControl $LatencyOutputTxt
})

$ServicesList.Add_SelectionChanged({
    $item = $ServicesList.SelectedItem
    if ($item) {
        $ServiceDescBox.Text = $item.Description
    }
})

$TasksList.Add_SelectionChanged({
    $item = $TasksList.SelectedItem
    if ($item) {
        $TaskDescBox.Text = $item.Description
    }
})

$ApplyServicesBtn.Add_Click({
    $item = $ServicesList.SelectedItem
    if ($item) {
        Apply-ServiceItem -Item $item -State "Disable"
    }
})

$ApplyTasksBtn.Add_Click({
    $item = $TasksList.SelectedItem
    if ($item) {
        Apply-TaskItem -Item $item -State "Disable"
    }
})

$GamingProfileBtn.Add_Click({
    Apply-GamingProfile
})

$StreamingProfileBtn.Add_Click({
    Apply-StreamingProfile
})

$WorkProfileBtn.Add_Click({
    Apply-WorkProfile
})

$PerformanceProfileBtn.Add_Click({
    Apply-PerformanceProfile
})

# ============================
# RUN WINDOW
# ============================

$window.ShowDialog() | Out-Null
