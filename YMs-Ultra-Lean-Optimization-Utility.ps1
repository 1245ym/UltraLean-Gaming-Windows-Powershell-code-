# =========================================================
# YM's Ultra Lean Optimization Utility
# Single-file PowerShell WPF Utility
# =========================================================

# -------------------- ADMIN CHECK --------------------
if (-not ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run PowerShell as Administrator."
    return
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -------------------- GLOBAL STATE --------------------
$Global:ActionQueue = @()
$Global:DryRunEnabled = $true
$Global:DangerMode = $false
$Global:LogPath = "$env:USERPROFILE\Documents\YM-UltraLean.log"

# -------------------- LOGGING --------------------
function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts | $Message" | Out-File -FilePath $Global:LogPath -Append -Encoding utf8
}

# -------------------- ACTION ENGINE --------------------
function Queue-Action {
    param(
        [string]$Type,
        [string]$Target,
        $Details
    )
    $Global:ActionQueue += [PSCustomObject]@{
        Type    = $Type
        Target  = $Target
        Details = $Details
    }
}

function Show-DryRun {
    $msg = "DRY RUN — NO CHANGES WILL BE MADE`n`n"
    foreach ($a in $Global:ActionQueue) {
        $msg += "✔ $($a.Type): $($a.Target)`n"
    }
    [System.Windows.MessageBox]::Show($msg, "Dry Run Preview")
}

function Execute-Actions {
    if ($Global:DryRunEnabled) {
        Show-DryRun
        return
    }

    Write-Log "=== EXECUTION START ==="

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
            "EnableService" {
                Set-Service -Name $a.Target -StartupType Automatic
                Start-Service -Name $a.Target -ErrorAction SilentlyContinue
            }
            "Registry" {
                $params = $a.Details
                Set-ItemProperty @params -Force
            }
        }
    }

    $Global:ActionQueue = @()
    Write-Log "=== EXECUTION END ==="
}

# -------------------- DATA --------------------
$Apps = @(
    @{ Name="Microsoft.XboxApp"; Desc="Xbox application"; System=$false },
    @{ Name="Microsoft.ZuneMusic"; Desc="Groove Music"; System=$false },
    @{ Name="Microsoft.WindowsMaps"; Desc="Offline maps"; System=$false },
    @{ Name="Microsoft.People"; Desc="Contacts app"; System=$true }
)

$Services = @(
    @{ Name="DiagTrack"; Desc="Telemetry service" },
    @{ Name="WSearch"; Desc="Windows Search indexing" },
    @{ Name="MapsBroker"; Desc="Maps background service" }
)

$Presets = @{
    "Gaming Beast" = @{
        Apps     = @("Microsoft.XboxApp","Microsoft.ZuneMusic")
        Services = @("DiagTrack","WSearch")
    }
    "Minimal" = @{
        Apps     = @("Microsoft.People","Microsoft.WindowsMaps")
        Services = @("DiagTrack")
    }
}

# -------------------- UI --------------------
Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="YM Ultra Lean Optimization Utility"
        Width="900" Height="600"
        Background="#111"
        Foreground="White"
        WindowStartupLocation="CenterScreen">

<Grid Margin="10">
<TabControl>

<TabItem Header="Overview">
<StackPanel>
<TextBlock FontSize="22" FontWeight="Bold" Text="YM Ultra Lean Optimization Utility"/>
<TextBlock Margin="0,10,0,0" TextWrapping="Wrap">
Safe-by-default Windows optimization tool.
Dry Run is enabled by default.
Danger Mode unlocks system apps.
Nothing runs unless you click Apply.
</TextBlock>
</StackPanel>
</TabItem>

<TabItem Header="Apps">
<ScrollViewer>
<StackPanel Name="AppPanel"/>
</ScrollViewer>
</TabItem>

<TabItem Header="Services">
<ScrollViewer>
<StackPanel Name="ServicePanel"/>
</ScrollViewer>
</TabItem>

<TabItem Header="Presets">
<StackPanel>
<ComboBox Name="PresetBox" Margin="0,0,0,10"/>
<Button Name="ApplyPreset" Content="Apply Preset"/>
</StackPanel>
</TabItem>

<TabItem Header="Controls">
<StackPanel>
<CheckBox Name="DryRunBox" IsChecked="True">Dry Run (Preview Only)</CheckBox>
<CheckBox Name="DangerBox">Danger Mode (Unlock System Apps)</CheckBox>
<Button Name="ApplyBtn" Margin="0,10,0,0">Apply Selected Actions</Button>
</StackPanel>
</TabItem>

</TabControl>
</Grid>
</Window>
"@

# -------------------- LOAD XAML (CORRECT METHOD) --------------------
$reader = New-Object System.IO.StringReader $XAML
$xmlReader = [System.Xml.XmlReader]::Create($reader)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

if (-not $Window) {
    throw "Failed to load UI."
}

# -------------------- CONTROL REFERENCES --------------------
$AppPanel     = $Window.FindName("AppPanel")
$ServicePanel = $Window.FindName("ServicePanel")
$PresetBox    = $Window.FindName("PresetBox")
$ApplyPreset  = $Window.FindName("ApplyPreset")
$ApplyBtn     = $Window.FindName("ApplyBtn")
$DryRunBox    = $Window.FindName("DryRunBox")
$DangerBox    = $Window.FindName("DangerBox")

# -------------------- POPULATE APPS --------------------
$AppCheckboxes = @{}

function Load-Apps {
    $AppPanel.Children.Clear()
    $AppCheckboxes.Clear()

    foreach ($app in $Apps) {
        if ($app.System -and -not $Global:DangerMode) { continue }

        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Content = "$($app.Name) — $($app.Desc)"
        $cb.Margin = "0,2,0,2"
        $AppPanel.Children.Add($cb)
        $AppCheckboxes[$app.Name] = $cb
    }
}

Load-Apps

# -------------------- POPULATE SERVICES --------------------
$ServiceCheckboxes = @{}
foreach ($svc in $Services) {
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = "$($svc.Name) — $($svc.Desc)"
    $cb.Margin = "0,2,0,2"
    $ServicePanel.Children.Add($cb)
    $ServiceCheckboxes[$svc.Name] = $cb
}

# -------------------- PRESETS --------------------
$Presets.Keys | ForEach-Object { $PresetBox.Items.Add($_) }

$ApplyPreset.Add_Click({
    $name = $PresetBox.SelectedItem
    if (-not $name) { return }

    foreach ($cb in $AppCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $ServiceCheckboxes.Values) { $cb.IsChecked = $false }

    foreach ($a in $Presets[$name].Apps) {
        if ($AppCheckboxes.ContainsKey($a)) {
            $AppCheckboxes[$a].IsChecked = $true
        }
    }
    foreach ($s in $Presets[$name].Services) {
        if ($ServiceCheckboxes.ContainsKey($s)) {
            $ServiceCheckboxes[$s].IsChecked = $true
        }
    }
})

# -------------------- CONTROLS --------------------
$DryRunBox.Add_Click({
    $Global:DryRunEnabled = [bool]$DryRunBox.IsChecked
})

$DangerBox.Add_Click({
    $Global:DangerMode = [bool]$DangerBox.IsChecked
    Load-Apps
})

$ApplyBtn.Add_Click({
    $Global:ActionQueue = @()

    foreach ($name in $AppCheckboxes.Keys) {
        if ($AppCheckboxes[$name].IsChecked) {
            Queue-Action "RemoveApp" $name $null
        }
    }

    foreach ($name in $ServiceCheckboxes.Keys) {
        if ($ServiceCheckboxes[$name].IsChecked) {
            Queue-Action "DisableService" $name $null
        }
    }

    Execute-Actions
})

# -------------------- SHOW UI --------------------
$Window.ShowDialog() | Out-Null

