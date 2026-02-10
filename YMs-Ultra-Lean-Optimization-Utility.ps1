# =========================================================
# YM Ultra Lean GAMING Optimization Utility
# Single-file PowerShell WPF Tool
# =========================================================

# -------------------- ADMIN CHECK --------------------
if (-not ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Run PowerShell as Administrator."
    return
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -------------------- GLOBAL STATE --------------------
$Global:ActionQueue = @()
$Global:DryRunEnabled = $true
$Global:DangerMode = $false
$Global:LogPath = "$env:USERPROFILE\Documents\YM-Gaming-Optimizer.log"

# -------------------- LOGGING --------------------
function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts | $Message" | Out-File -FilePath $Global:LogPath -Append -Encoding utf8
}

# -------------------- ACTION ENGINE --------------------
function Queue-Action {
    param([string]$Type,[string]$Target,$Details)
    $Global:ActionQueue += [PSCustomObject]@{
        Type=$Type; Target=$Target; Details=$Details
    }
}

function Show-DryRun {
    $msg = "🎮 GAMING DRY RUN — NO CHANGES MADE`n`n"
    foreach ($a in $Global:ActionQueue) {
        $msg += "✔ $($a.Type): $($a.Target)`n"
    }
    [System.Windows.MessageBox]::Show($msg,"Dry Run Preview")
}

function Execute-Actions {
    if ($Global:DryRunEnabled) { Show-DryRun; return }

    Write-Log "=== GAMING OPTIMIZATION START ==="

    foreach ($a in $Global:ActionQueue) {
        Write-Log "$($a.Type): $($a.Target)"
        switch ($a.Type) {
            "RemoveApp" {
                Get-AppxPackage -AllUsers -Name $a.Target -ErrorAction SilentlyContinue |
                    Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            }
            "DisableService" {
                Stop-Service -Name $a.Target -Force -ErrorAction SilentlyContinue
                Set-Service -Name $a.Target -StartupType Disabled
            }
            "Registry" {
                $params = $a.Details
                Set-ItemProperty @params -Force
            }
        }
    }

    $Global:ActionQueue=@()
    Write-Log "=== GAMING OPTIMIZATION END ==="
}

# -------------------- GAMING DATA --------------------
$Apps = @(
    @{Name="Microsoft.XboxApp";Desc="Xbox App (not needed for most PC gaming)";System=$false},
    @{Name="Microsoft.XboxGamingOverlay";Desc="Xbox Game Bar overlay";System=$true},
    @{Name="Microsoft.ZuneMusic";Desc="Groove Music background services";System=$false},
    @{Name="Microsoft.People";Desc="Contacts app, background sync";System=$true},
    @{Name="Microsoft.WindowsMaps";Desc="Offline maps services";System=$false}
)

$Services = @(
    @{Name="DiagTrack";Desc="Telemetry (CPU + disk usage)"},
    @{Name="WSearch";Desc="Indexing causes disk & CPU spikes"},
    @{Name="SysMain";Desc="Prefetch/Superfetch causes stutter on SSDs"},
    @{Name="MapsBroker";Desc="Maps background tasks"}
)

$Presets = @{
    "FPS MAXIMUM" = @{
        Apps=@("Microsoft.XboxGamingOverlay","Microsoft.ZuneMusic")
        Services=@("DiagTrack","WSearch","SysMain")
    }
    "LOW LATENCY" = @{
        Apps=@("Microsoft.XboxApp","Microsoft.People")
        Services=@("DiagTrack","MapsBroker")
    }
    "COMPETITIVE HARDCORE" = @{
        Apps=@("Microsoft.XboxApp","Microsoft.XboxGamingOverlay","Microsoft.ZuneMusic","Microsoft.People")
        Services=@("DiagTrack","WSearch","SysMain","MapsBroker")
    }
}

# -------------------- UI --------------------
Add-Type -AssemblyName PresentationFramework

$XAML=@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
Title="YM Ultra Lean GAMING Optimizer"
Width="900" Height="600"
Background="#0b0b0b" Foreground="White"
WindowStartupLocation="CenterScreen">

<Grid Margin="10">
<TabControl>

<TabItem Header="Overview">
<StackPanel>
<TextBlock FontSize="22" FontWeight="Bold" Text="🎮 YM GAMING OPTIMIZATION UTILITY"/>
<TextBlock Margin="0,10,0,0" TextWrapping="Wrap">
Designed for FPS stability, reduced latency, and background task elimination.
Dry Run is ON by default.
Danger Mode unlocks aggressive gaming tweaks.
Nothing applies unless you click APPLY.
</TextBlock>
</StackPanel>
</TabItem>

<TabItem Header="Gaming Apps">
<ScrollViewer>
<StackPanel Name="AppPanel"/>
</ScrollViewer>
</TabItem>

<TabItem Header="Gaming Services">
<ScrollViewer>
<StackPanel Name="ServicePanel"/>
</ScrollViewer>
</TabItem>

<TabItem Header="Gaming Presets">
<StackPanel>
<ComboBox Name="PresetBox" Margin="0,0,0,10"/>
<Button Name="ApplyPreset" Content="Apply Gaming Preset"/>
</StackPanel>
</TabItem>

<TabItem Header="Controls">
<StackPanel>
<CheckBox Name="DryRunBox" IsChecked="True">Dry Run (Preview Gaming Changes)</CheckBox>
<CheckBox Name="DangerBox">Danger Mode (Hardcore Gaming Tweaks)</CheckBox>
<Button Name="ApplyBtn" Margin="0,10,0,0">APPLY GAMING OPTIMIZATION</Button>
</StackPanel>
</TabItem>

</TabControl>
</Grid>
</Window>
"@

# -------------------- LOAD UI --------------------
$reader=New-Object System.IO.StringReader $XAML
$xmlReader=[System.Xml.XmlReader]::Create($reader)
$Window=[Windows.Markup.XamlReader]::Load($xmlReader)
if(-not $Window){throw "UI failed to load"}

# -------------------- CONTROLS --------------------
$AppPanel=$Window.FindName("AppPanel")
$ServicePanel=$Window.FindName("ServicePanel")
$PresetBox=$Window.FindName("PresetBox")
$ApplyPreset=$Window.FindName("ApplyPreset")
$ApplyBtn=$Window.FindName("ApplyBtn")
$DryRunBox=$Window.FindName("DryRunBox")
$DangerBox=$Window.FindName("DangerBox")

# -------------------- LOAD APPS --------------------
$AppCheckboxes=@{}
function Load-Apps {
    $AppPanel.Children.Clear()
    $AppCheckboxes.Clear()
    foreach($app in $Apps){
        if($app.System -and -not $Global:DangerMode){continue}
        $cb=New-Object System.Windows.Controls.CheckBox
        $cb.Content="$($app.Name) — $($app.Desc)"
        $cb.Margin="0,2,0,2"
        $AppPanel.Children.Add($cb)
        $AppCheckboxes[$app.Name]=$cb
    }
}
Load-Apps

# -------------------- LOAD SERVICES --------------------
$ServiceCheckboxes=@{}
foreach($svc in $Services){
    $cb=New-Object System.Windows.Controls.CheckBox
    $cb.Content="$($svc.Name) — $($svc.Desc)"
    $cb.Margin="0,2,0,2"
    $ServicePanel.Children.Add($cb)
    $ServiceCheckboxes[$svc.Name]=$cb
}

# -------------------- PRESETS --------------------
$Presets.Keys | ForEach-Object { $PresetBox.Items.Add($_) }

$ApplyPreset.Add_Click({
    $p=$PresetBox.SelectedItem
    if(-not $p){return}
    $AppCheckboxes.Values | ForEach-Object{$_.IsChecked=$false}
    $ServiceCheckboxes.Values | ForEach-Object{$_.IsChecked=$false}
    foreach($a in $Presets[$p].Apps){ if($AppCheckboxes[$a]){$AppCheckboxes[$a].IsChecked=$true}}
    foreach($s in $Presets[$p].Services){ if($ServiceCheckboxes[$s]){$ServiceCheckboxes[$s].IsChecked=$true}}
})

# -------------------- CONTROLS --------------------
$DryRunBox.Add_Click({$Global:DryRunEnabled=[bool]$DryRunBox.IsChecked})
$DangerBox.Add_Click({$Global:DangerMode=[bool]$DangerBox.IsChecked;Load-Apps})

$ApplyBtn.Add_Click({
    $Global:ActionQueue=@()
    foreach($n in $AppCheckboxes.Keys){if($AppCheckboxes[$n].IsChecked){Queue-Action "RemoveApp" $n $null}}
    foreach($n in $ServiceCheckboxes.Keys){if($ServiceCheckboxes[$n].IsChecked){Queue-Action "DisableService" $n $null}}
    Execute-Actions
})

# -------------------- SHOW --------------------
$Window.ShowDialog() | Out-Null
