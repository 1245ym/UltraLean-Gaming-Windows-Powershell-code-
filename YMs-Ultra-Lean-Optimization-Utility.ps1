Add-Type -AssemblyName PresentationFramework

# ---------------- CORE ----------------

function Create-RestorePoint {
    Checkpoint-Computer -Description "WinTweak Control Center" -RestorePointType MODIFY_SETTINGS
}

function Apply-Registry($Path, $Name, $Value) {
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force
}

function Undo-Registry($Path, $Name) {
    Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
}

# ---------------- TELEMETRY ----------------

function Set-Telemetry($Level) {
    switch ($Level) {
        "Minimal" {
            Apply-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 1
        }
        "Moderate" {
            Apply-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
            Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
        }
        "Heavy" {
            Apply-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
            "DiagTrack","dmwappushservice","WerSvc" | ForEach-Object {
                Set-Service $_ -StartupType Disabled -ErrorAction SilentlyContinue
            }
        }
    }
}

function Undo-Telemetry {
    Undo-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry"
    Set-Service DiagTrack -StartupType Automatic -ErrorAction SilentlyContinue
}

# ---------------- SERVICES ----------------

function Set-Services($Services, $Mode) {
    foreach ($svc in $Services) {
        if ($Mode -eq "Disable") {
            Stop-Service $svc -ErrorAction SilentlyContinue
            Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
        } else {
            Set-Service $svc -StartupType Automatic -ErrorAction SilentlyContinue
        }
    }
}

# ---------------- GAMING ----------------

function Apply-GamingTweaks {
    powercfg /setactive SCHEME_MIN
    Apply-Registry "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
    Apply-Registry "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1
    Apply-Registry "HKCU:\Software\Microsoft\GameBar" "ShowStartupPanel" 0
    Apply-Registry "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0
}

function Undo-GamingTweaks {
    Apply-Registry "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 1
    Apply-Registry "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 20
}

# ---------------- CURATED APPS ----------------

$Apps = @(
    @{ Name="Xbox App"; Pkg="Microsoft.XboxApp"; Desc="Xbox console companion and social features" },
    @{ Name="Xbox Game Bar"; Pkg="Microsoft.XboxGamingOverlay"; Desc="In-game overlay, DVR, widgets" },
    @{ Name="Feedback Hub"; Pkg="Microsoft.WindowsFeedbackHub"; Desc="Send feedback to Microsoft" },
    @{ Name="People"; Pkg="Microsoft.People"; Desc="Contacts integration" },
    @{ Name="Movies and TV"; Pkg="Microsoft.ZuneVideo"; Desc="Media playback app" },
    @{ Name="Groove Music"; Pkg="Microsoft.ZuneMusic"; Desc="Music player" },
    @{ Name="Solitaire"; Pkg="Microsoft.MicrosoftSolitaireCollection"; Desc="Games" }
)

function Remove-App($Pkg) {
    Get-AppxPackage $Pkg -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
}

function Restore-App($Pkg) {
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -eq $Pkg} |
    ForEach-Object {
        Add-AppxPackage -Register "$($_.InstallLocation)\AppXManifest.xml" -DisableDevelopmentMode
    }
}

# ---------------- ADVANCED ALL APPS ----------------

$AllApps = Get-AppxPackage -AllUsers | Sort-Object Name

function Get-AppCategory {
    param($pkg)
    if ($pkg.IsFramework) { return "Framework Package" }
    if ($pkg.Name -like "*Store*") { return "Store Infrastructure" }
    if ($pkg.Name -like "*Shell*" -or $pkg.Name -like "*StartMenu*" -or $pkg.Name -like "*StartMenuExperience*") {
        return "Shell Component"
    }
    if ($pkg.SignatureKind -eq "System") { return "System Component" }
    return "User or OEM App"
}

# Curated app checkboxes
$appCheckboxes = ""
foreach ($a in $Apps) {
    $safe = $a.Name.Replace(" ","_")
    $nameEsc = [System.Security.SecurityElement]::Escape($a.Name)
    $descEsc = [System.Security.SecurityElement]::Escape($a.Desc)
    $appCheckboxes += "<CheckBox x:Name='APP_$safe' Content='$nameEsc - $descEsc' Margin='0,3,0,0'/>`n"
}

# All apps checkboxes (index-based unique names)
$allAppCheckboxes = ""
$index = 0
foreach ($pkg in $AllApps) {
    if (-not $pkg.Name) { continue }

    $nameEsc = [System.Security.SecurityElement]::Escape($pkg.Name)
    $cat = Get-AppCategory -pkg $pkg
    $catEsc = [System.Security.SecurityElement]::Escape($cat)
    $fullEsc = [System.Security.SecurityElement]::Escape($pkg.PackageFullName)

    $content = "$nameEsc [$catEsc] - $fullEsc"
    $contentEsc = [System.Security.SecurityElement]::Escape($content)

    $cbName = "PKG_{0}" -f $index
    $allAppCheckboxes += "<CheckBox x:Name='$cbName' Content='$contentEsc' Margin='0,2,0,0'/>`n"
    $index++
}

# ---------------- UI ----------------

$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinTweak Control Center"
        Height="700" Width="1000"
        WindowStartupLocation="CenterScreen">

<Grid Margin="12">
<Grid.RowDefinitions>
<RowDefinition Height="*"/>
<RowDefinition Height="Auto"/>
</Grid.RowDefinitions>

<TabControl>

<TabItem Header="Privacy">
<StackPanel Margin="10">
<TextBlock Text="Telemetry Level" FontWeight="Bold"/>
<ComboBox x:Name="TelemetryLevel" Width="220">
<ComboBoxItem Content="Minimal"/>
<ComboBoxItem Content="Moderate"/>
<ComboBoxItem Content="Heavy"/>
</ComboBox>
</StackPanel>
</TabItem>

<TabItem Header="Gaming">
<StackPanel Margin="10">
<TextBlock Text="Gaming Optimizations" FontWeight="Bold"/>
<CheckBox x:Name="GameTweaks" Content="Enable Gaming Performance Tweaks"/>
<TextBlock Text="- High performance power plan
- Disable Game DVR
- Optimize multimedia scheduling"
Margin="20,5,0,0" Foreground="Gray"/>
</StackPanel>
</TabItem>

<TabItem Header="Services">
<StackPanel Margin="10">
<TextBlock Text="Optional Background Services" FontWeight="Bold"/>
<CheckBox x:Name="SvcXbox" Content="Disable Xbox Services"/>
<TextBlock Text="Affects Xbox related background services." Margin="20,5,0,0" Foreground="Gray"/>
<CheckBox x:Name="SvcSearch" Content="Disable Search Indexing"/>
<TextBlock Text="May impact Start menu and file search speed." Margin="20,5,0,0" Foreground="Gray"/>
<CheckBox x:Name="SvcMaps" Content="Disable Maps Services"/>
<TextBlock Text="Disables background map data services." Margin="20,5,0,0" Foreground="Gray"/>
</StackPanel>
</TabItem>

<TabItem Header="Apps">
<ScrollViewer>
<StackPanel Margin="10">
<TextBlock Text="Curated Microsoft Apps" FontWeight="Bold"/>
$appCheckboxes
</StackPanel>
</ScrollViewer>
</TabItem>

<TabItem Header="All Apps Advanced">
<ScrollViewer>
<StackPanel Margin="10">
<TextBlock Text="All Appx Packages (Advanced - Can Break Windows)" FontWeight="Bold" Foreground="Red"/>
<TextBlock Text="Each entry shows: Name [Category] - PackageFullName" Margin="0,5,0,10" Foreground="Gray"/>
$allAppCheckboxes
</StackPanel>
</ScrollViewer>
</TabItem>

<TabItem Header="Safety">
<StackPanel Margin="10">
<CheckBox x:Name="RestorePoint" Content="Create Restore Point Before Applying" IsChecked="True"/>
<TextBlock Text="Undo restores telemetry, gaming tweaks, and services. App removal may not be fully reversible." Margin="0,10,0,0"/>
</StackPanel>
</TabItem>

</TabControl>

<StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right">
<Button x:Name="UndoBtn" Content="Undo" Width="110" Margin="5"/>
<Button x:Name="ApplyBtn" Content="Apply" Width="110" Margin="5"/>
</StackPanel>

</Grid>
</Window>
"@

[xml]$XAML = $XAML
$reader = New-Object System.Xml.XmlNodeReader $XAML
$Window = [Windows.Markup.XamlReader]::Load($reader)

# ---------------- LOGIC ----------------

$ApplyBtn = $Window.FindName("ApplyBtn")
$UndoBtn  = $Window.FindName("UndoBtn")

$ApplyBtn.Add_Click({
    if ($Window.FindName("RestorePoint").IsChecked) { Create-RestorePoint }

    Set-Telemetry $Window.FindName("TelemetryLevel").Text

    if ($Window.FindName("GameTweaks").IsChecked) { Apply-GamingTweaks }

    if ($Window.FindName("SvcXbox").IsChecked) {
        Set-Services @("XblAuthManager","XblGameSave","XboxNetApiSvc") "Disable"
    }
    if ($Window.FindName("SvcSearch").IsChecked) {
        Set-Services @("WSearch") "Disable"
    }
    if ($Window.FindName("SvcMaps").IsChecked) {
        Set-Services @("MapsBroker") "Disable"
    }

    foreach ($a in $Apps) {
        $cbName = "APP_{0}" -f ($a.Name.Replace(" ","_"))
        $cb = $Window.FindName($cbName)
        if ($cb -and $cb.IsChecked) {
            Remove-App $a.Pkg
        }
    }

    for ($i = 0; $i -lt $AllApps.Count; $i++) {
        $pkg = $AllApps[$i]
        if (-not $pkg.Name) { continue }
        $cbName = "PKG_{0}" -f $i
        $cb = $Window.FindName($cbName)
        if ($cb -and $cb.IsChecked) {
            try {
                Remove-AppxPackage -AllUsers -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
            } catch {}
            try {
                $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $pkg.Name }
                foreach ($p in $prov) {
                    Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction SilentlyContinue
                }
            } catch {}
        }
    }

    [System.Windows.MessageBox]::Show("Tweaks and removals applied. Some changes may require restart.")
})

$UndoBtn.Add_Click({
    Undo-Telemetry
    Undo-GamingTweaks
    Set-Services @("XblAuthManager","XblGameSave","XboxNetApiSvc","WSearch","MapsBroker") "Enable"

    foreach ($a in $Apps) {
        Restore-App $a.Pkg
    }

    [System.Windows.MessageBox]::Show("Undo completed for telemetry, gaming tweaks, services, and curated apps.")
})

$Window.ShowDialog() | Out-Null

