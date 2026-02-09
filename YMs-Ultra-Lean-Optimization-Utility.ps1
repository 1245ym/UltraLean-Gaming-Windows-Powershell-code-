
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

# ---------------- APPS ----------------

$Apps = @(
    @{ Name="Xbox App"; Pkg="Microsoft.XboxApp"; Desc="Xbox console companion and social features" },
    @{ Name="Xbox Game Bar"; Pkg="Microsoft.XboxGamingOverlay"; Desc="In-game overlay, DVR, widgets" },
    @{ Name="Feedback Hub"; Pkg="Microsoft.WindowsFeedbackHub"; Desc="Send feedback to Microsoft" },
    @{ Name="People"; Pkg="Microsoft.People"; Desc="Contacts integration" },
    @{ Name="Movies & TV"; Pkg="Microsoft.ZuneVideo"; Desc="Media playback app" },
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

# ---------------- UI ----------------

# Build dynamic checkboxes
$appCheckboxes = ""
foreach ($a in $Apps) {
    $safe = $a.Name.Replace(" ","_")
    $appCheckboxes += "<CheckBox x:Name='APP_$safe' Content='$($a.Name) – $($a.Desc)' Margin='0,3,0,0'/>`n"
}

# Build XAML (as plain string first)
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinTweak Control Center"
        Height="700" Width="800"
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
<TextBlock Text="• High performance power plan
• Disable Game DVR
• Optimize multimedia scheduling"
Margin="20,5,0,0" Foreground="Gray"/>
</StackPanel>
</TabItem>

<TabItem Header="Services">
<StackPanel Margin="10">
<TextBlock Text="Optional Background Services" FontWeight="Bold"/>
<CheckBox x:Name="SvcXbox" Content="Disable Xbox Services"/>
<CheckBox x:Name="SvcSearch" Content="Disable Search Indexing"/>
<CheckBox x:Name="SvcMaps" Content="Disable Maps Services"/>
</StackPanel>
</TabItem>

<TabItem Header="Apps">
<ScrollViewer>
<StackPanel Margin="10">
<TextBlock Text="Microsoft Apps (Toggle Individually)" FontWeight="Bold"/>
$appCheckboxes
</StackPanel>
</ScrollViewer>
</TabItem>

<TabItem Header="Safety">
<StackPanel Margin="10">
<CheckBox x:Name="RestorePoint" Content="Create Restore Point Before Applying" IsChecked="True"/>
<TextBlock Text="Undo restores services, telemetry, and gaming tweaks. Apps require Store access."
Margin="0,10,0,0"/>
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

# Convert to XML AFTER variable expansion
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
        $cb = $Window.FindName("APP_$($a.Name.Replace(" ","_"))")
        if ($cb.IsChecked) { Remove-App $a.Pkg }
    }

    [System.Windows.MessageBox]::Show("Tweaks applied successfully.")
})

$UndoBtn.Add_Click({
    Undo-Telemetry
    Undo-GamingTweaks
    Set-Services @("XblAuthManager","XblGameSave","XboxNetApiSvc","WSearch","MapsBroker") "Enable"

    foreach ($a in $Apps) { Restore-App $a.Pkg }

    [System.Windows.MessageBox]::Show("Undo completed.")
})

$Window.ShowDialog() | Out-Null

