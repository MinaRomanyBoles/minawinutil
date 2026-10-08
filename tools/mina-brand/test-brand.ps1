# Noninteractive branding smoke test. Runs in Windows PowerShell 5.1 STA,
# where WPF is available, and does not open a browser or alter the host OS.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$imagePath = Join-Path $root 'tools/mina-brand/mina-profile.png'
if (-not (Test-Path $imagePath)) { throw 'Rendered developer image is missing' }
$sync = [Hashtable]::Synchronized(@{})
$sync.preferences = @{}
$sync.RenderedAssetCache = [Hashtable]::Synchronized(@{})
$sync.preferences.MinaBrandPngBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($imagePath))

. (Join-Path $root 'functions/private/Get-MinaBrandBitmap.ps1')
. (Join-Path $root 'functions/private/New-MinaProfileCard.ps1')

$image = Get-MinaBrandBitmap
if (-not $image -or $image.PixelWidth -lt 100 -or $image.PixelHeight -lt 100) {
    throw 'WPF could not decode the embedded photo'
}
if (-not $image.IsFrozen) { throw 'Decoded bitmap must be frozen for runspace sharing' }

$window = [Windows.Window]::new()
$window.Icon = $image
$card = New-MinaProfileCard
$window.Content = $card
$window.Measure([Windows.Size]::new(220, 650))
$window.Arrange([Windows.Rect]::new(0, 0, 220, 650))

$portrait = @($card.Child.Children | Where-Object { $_ -is [Windows.Controls.Image] })
if ($portrait.Count -ne 1 -or -not $portrait[0].Source) {
    throw 'Mina portrait missing from WPF sidebar card'
}

$labels = @($card.Child.Children | Where-Object { $_ -is [Windows.Controls.TextBlock] } | ForEach-Object { $_.Text })
foreach ($expected in @('Mina Romany', '01115842589', 'minaromanyofficial@gmail.com')) {
    if ($labels -notcontains $expected) { throw "Sidebar missing developer detail: $expected" }
}

$buttons = [System.Collections.Generic.List[object]]::new()
foreach ($child in $card.Child.Children) {
    if ($child -is [Windows.Controls.Button]) { [void]$buttons.Add($child) }
    if ($child -is [Windows.Controls.WrapPanel]) {
        foreach ($button in $child.Children) {
            if ($button -is [Windows.Controls.Button]) { [void]$buttons.Add($button) }
        }
    }
}

$targets = @{
    'minaromany.online' = 'https://minaromany.online'
    'Facebook' = 'https://www.facebook.com/MinaRomanyOfficial'
    'GitHub' = 'https://github.com/MinaRomanyBoles'
    'LinkedIn' = 'https://www.linkedin.com/in/minaromany/'
}
foreach ($name in $targets.Keys) {
    $matching = @($buttons | Where-Object { $_.Content -eq $name -and $_.Tag -eq $targets[$name] })
    if ($matching.Count -ne 1) { throw "Sidebar link missing or incorrect: $name" }
}

Write-Host 'PASS: WPF image, window icon, sidebar layout, developer details and four link-button targets'
