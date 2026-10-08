# Noninteractive Windows PowerShell 5.1 STA smoke test for the compact card.
# Validates both separately embedded images, layout constraints and link targets.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$logoPath = Join-Path $root 'tools/mina-brand/mina-profile.png'
$portraitPath = Join-Path $root 'tools/mina-brand/mina-portrait.png'
foreach ($file in @($logoPath, $portraitPath)) {
    if (-not (Test-Path -LiteralPath $file)) { throw "Missing rendered image: $file" }
}

$sync = [Hashtable]::Synchronized(@{})
$sync.preferences = @{}
$sync.RenderedAssetCache = [Hashtable]::Synchronized(@{})
$sync.preferences.MinaBrandPngBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($logoPath))
$sync.preferences.MinaPortraitPngBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($portraitPath))

. (Join-Path $root 'functions/private/Get-MinaBrandBitmap.ps1')
. (Join-Path $root 'functions/private/Get-MinaProfileBitmap.ps1')
. (Join-Path $root 'functions/private/New-MinaProfileCard.ps1')

$logo = Get-MinaBrandBitmap
$picture = Get-MinaProfileBitmap
if (-not $logo -or -not $picture) { throw 'One or more WPF images did not decode' }
if ($logo.PixelWidth -lt 100 -or $picture.PixelWidth -lt 100) { throw 'Embedded images are too small' }
if (-not $logo.IsFrozen -or -not $picture.IsFrozen) { throw 'Images must be frozen across runspaces' }
if ($sync.preferences.MinaBrandPngBase64 -eq $sync.preferences.MinaPortraitPngBase64) {
    throw 'Developer photo must be independent of the original window icon'
}

$window = [Windows.Window]::new()
$window.Icon = $logo
$card = New-MinaProfileCard
$window.Content = $card
$window.Measure([Windows.Size]::new(240, 800))
$window.Arrange([Windows.Rect]::new(0, 0, 240, 800))
if ($card.Width -gt 220 -or $card.DesiredSize.Width -gt 230) {
    throw "Developer card makes the application column too narrow: $($card.DesiredSize.Width)"
}

$images = @($card.Child.Children | Where-Object { $_ -is [Windows.Controls.Image] })
if ($images.Count -ne 1 -or -not [object]::ReferenceEquals($images[0].Source, $picture)) {
    throw 'The large card portrait must use the new picture, not the application icon'
}
if ($images[0].Width -lt 125 -or $images[0].Height -lt 125 -or -not $images[0].Clip) {
    throw 'Portrait must be large and circular'
}

$labels = @($card.Child.Children | Where-Object { $_ -is [Windows.Controls.TextBlock] } | ForEach-Object { $_.Text })
foreach ($expected in @('Mina Romany', '01115842589', 'minaromanyofficial@gmail.com')) {
    if ($labels -notcontains $expected) { throw "Missing developer detail: $expected" }
}

$buttons = @($card.Child.Children | Where-Object { $_ -is [Windows.Controls.Button] })
$targets = @{
    'minaromany.online' = 'https://minaromany.online'
    'Facebook' = 'https://www.facebook.com/MinaRomanyOfficial'
    'GitHub' = 'https://github.com/MinaRomanyBoles'
    'LinkedIn' = 'https://www.linkedin.com/in/minaromany/'
}
if ($buttons.Count -ne 4) { throw 'Expected four vertically stacked buttons' }
foreach ($name in $targets.Keys) {
    $matching = @($buttons | Where-Object { $_.Content -eq $name -and $_.Tag -eq $targets[$name] -and $_.Width -le 190 })
    if ($matching.Count -ne 1) { throw "Sidebar action missing or too wide: $name" }
}
if (@($card.Child.Children | Where-Object { $_ -is [Windows.Controls.WrapPanel] }).Count -gt 0) {
    throw 'A horizontal WrapPanel would stretch the sidebar again'
}

Write-Host 'PASS: compact 218px sidebar, 132px circular portrait, unchanged window icon, details and vertical links'
