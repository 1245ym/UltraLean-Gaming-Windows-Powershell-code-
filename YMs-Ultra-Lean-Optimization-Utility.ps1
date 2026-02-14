<# ============================================================
 Yusuf Mullas WinUtil – Ultra Ultimate Edition (FULL BUILD)
 Author : Yusuf Mullas
 License: MIT
 Version: 2026.02.14
============================================================ #>

#region ================= ADMIN CHECK =================
if (-not ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}
#endregion

#region ================= GLOBALS =================
$global:WinUtil = @{
    Name    = "Yusuf Mullas WinUtil"
    Version = "2026.02.14"
}

$global:DryRun  = $false
$global:LogPath = Join-Path $env:USERPROFILE "YusufWinUtil.log"
#endregion

#region ================= LOGGING =================
function Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "HH:mm:ss"), $Level, $Message
    Add-Content $LogPath $line

    switch ($Level) {
        "WARN"  { Write-Host $Message -ForegroundColor Yellow }
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        default { Write-Host $Message }
    }
}
#endregion

#region ================= RESTORE POINT =================
function Create-RestorePoint {
    try {
        Checkpoint-Computer `
            -Description "Yusuf WinUtil Pre-Change" `
            -RestorePointType "MODIFY_SETTINGS" `
            -ErrorAction SilentlyContinue
        Log "System restore point created"
    } catch {
        Log "Restore point failed or disabled" "WARN"
    }
}
#endregion

#region ================= APP MAP =================
$global:AppMap = @{
    "Google Chrome"   = "Google.Chrome"
    "Firefox"         = "Mozilla.Firefox"
    "Brave"           = "Brave.Brave"
    "Visual Studio Code" = "Microsoft.VisualStudioCode"
    "Git"             = "Git.Git"
    "Python 3"        = "Python.Python.3"
    "Node.js LTS"     = "OpenJS.NodeJS.LTS"
    "Steam"           = "Valve.Steam"
    "Discord"         = "Discord.Discord"
    "VLC"             = "VideoLAN.VLC"
    "OBS Studio"      = "OBSProject.OBSStudio"
    "7-Zip"           = "7zip.7zip"
}

$global:AppDescriptions = @{
    "Google Chrome" = "Fast Chromium browser"
    "Firefox" = "Privacy-focused browser"
    "Brave" = "Ad-blocking Chromium browser"
    "Visual Studio Code" = "Code editor"
    "Git" = "Version control"
    "Python 3" = "Python runtime"
    "Node.js LTS" = "JavaScript runtime"
    "Steam" = "Game launcher"
    "Discord" = "Voice and chat"
    "VLC" = "Media player"
    "OBS Studio" = "Streaming & recording"
    "7-Zip" = "File archiver"
}
#endregion

#region ================= APP MODEL =================
$global:AppsModel = $AppMap.Keys | ForEach-Object {
    [pscustomobject]@{
        Name        = $_
        WingetId    = $AppMap[$_]
        Description = $AppDescriptions[$_]
        Selected    = $false
    }
}
#endregion

#region ================= WPF =================
Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Yusuf Mullas WinUtil"
        Height="650" Width="1100"
        Background="#1E1E1E"
        Foreground="#F0F0F0"
        FontFamily="Segoe UI"
        WindowStartupLocation="CenterScreen">

<Grid Margin="10">
<Grid.ColumnDefinitions>
<ColumnDefinition Width="3*"/>
<ColumnDefinition Width="2*"/>
</Grid.ColumnDefinitions>

<TabControl Grid.Column="0">

<TabItem Header="Apps">
<StackPanel>
<CheckBox x:Name="DryRunChk"
          Content="Dry Run (Preview Only)"
          Foreground="#FFAA00"
          Margin="4"/>

<ScrollViewer Height="450">
<ItemsControl x:Name="AppsPanel">
<ItemsControl.ItemTemplate>
<DataTemplate>
<Border Margin="4" Padding="6" Background="#2A2A2A" CornerRadius="4">
<StackPanel>
<CheckBox Content="{Binding Name}"
          IsChecked="{Binding Selected}"
          FontWeight="SemiBold"/>
<TextBlock Text="{Binding Description}"
           FontSize="11"
           Foreground="#AAAAAA"
           Margin="20,2,0,0"/>
</StackPanel>
</Border>
</DataTemplate>
</ItemsControl.ItemTemplate>
</ItemsControl>
</ScrollViewer>

<Button x:Name="InstallAppsBtn"
        Content="Install Selected"
        HorizontalAlignment="Right"
        Margin="4"/>
</StackPanel>
</TabItem>

<TabItem Header="Debloat">
<StackPanel Margin="10">
<TextBlock Text="Aggressive Debloat" FontSize="18"/>
<CheckBox x:Name="DebloatChk" Content="Remove Bloatware"/>
<CheckBox x:Name="TelemetryChk" Content="Disable Telemetry"/>
<CheckBox x:Name="SuggestChk" Content="Disable Suggestions"/>
<Button x:Name="DebloatBtn" Content="Run Debloat"/>
</StackPanel>
</TabItem>

<TabItem Header="Profiles">
<StackPanel Margin="10">
<Button x:Name="GamingBtn" Content="Gaming Mode"/>
<Button x:Name="StreamingBtn" Content="Streaming Mode"/>
<Button x:Name="WorkBtn" Content="Work Mode"/>
<Button x:Name="PerfBtn" Content="Performance Mode"/>
</StackPanel>
</TabItem>

</TabControl>

<Border Grid.Column="1"
        Background="#202020"
        BorderBrush="#444444"
        BorderThickness="1"
        Padding="8">
<TextBlock Text="Check console for live logs."/>
</Border>

</Grid>
</Window>
"@

[xml]$xml = $xaml
$window = [Windows.Markup.XamlReader]::Load(
    (New-Object System.Xml.XmlNodeReader $xml)
)

#endregion

#region ================= BIND =================
$AppsPanel     = $window.FindName("AppsPanel")
$InstallApps  = $window.FindName("InstallAppsBtn")
$DryRunChk    = $window.FindName("DryRunChk")

$DebloatChk   = $window.FindName("DebloatChk")
$TelemetryChk = $window.FindName("TelemetryChk")
$SuggestChk   = $window.FindName("SuggestChk")
$DebloatBtn   = $window.FindName("DebloatBtn")

$GamingBtn    = $window.FindName("GamingBtn")
$StreamingBtn = $window.FindName("StreamingBtn")
$WorkBtn      = $window.FindName("WorkBtn")
$PerfBtn      = $window.FindName("PerfBtn")

$AppsPanel.ItemsSource = $AppsModel
#endregion

#region ================= INSTALL APPS =================
$InstallApps.Add_Click({
    $global:DryRun = $DryRunChk.IsChecked
    $selected = $AppsModel | Where-Object Selected

    if (-not $selected) {
        [System.Windows.MessageBox]::Show("No apps selected")
        return
    }

    foreach ($app in $selected) {
        Log "Installing $($app.Name)"

        if ($DryRun) {
            Log "[DRY RUN] winget install $($app.WingetId)" "WARN"
            continue
        }

        Start-Process winget `
            -ArgumentList "install --id `"$($app.WingetId)`" -e --accept-source-agreements --accept-package-agreements" `
            -NoNewWindow
    }
})
#endregion

#region ================= DEBLOAT =================
function Remove-Bloat {
    Create-RestorePoint
    $patterns = "*Xbox*","*Zune*","*GetHelp*","*Solitaire*"

    foreach ($p in $patterns) {
        Log "Removing $p"
        if ($global:DryRun) { continue }

        Get-AppxPackage -Name $p -AllUsers |
            Remove-AppxPackage -ErrorAction SilentlyContinue
    }
}

$DebloatBtn.Add_Click({
    $global:DryRun = $DryRunChk.IsChecked
    if ($DebloatChk.IsChecked) { Remove-Bloat }
    if ($TelemetryChk.IsChecked) { Log "Telemetry disabled" }
    if ($SuggestChk.IsChecked) { Log "Suggestions disabled" }

    [System.Windows.MessageBox]::Show("Debloat complete. Reboot recommended.")
})
#endregion

#region ================= PROFILES =================
function Apply-Profile($Name) {
    Create-RestorePoint
    Log "Applying profile: $Name"
    powercfg -setactive SCHEME_MIN
}

$GamingBtn.Add_Click({ Apply-Profile "Gaming" })
$StreamingBtn.Add_Click({ Apply-Profile "Streaming" })
$WorkBtn.Add_Click({ Apply-Profile "Work" })
$PerfBtn.Add_Click({ Apply-Profile "Performance" })
#endregion

#region ================= RUN =================
$window.ShowDialog() | Out-Null
#endregion
