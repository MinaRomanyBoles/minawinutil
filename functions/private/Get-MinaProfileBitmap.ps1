function Get-MinaProfileBitmap {
    <#
    .SYNOPSIS
        Loads the separately embedded portrait for Mina's developer card.
        The original Get-MinaBrandBitmap still owns the program/window icon.
    #>
    $cached = $sync.RenderedAssetCache['MinaProfileBitmap']
    if ($cached) { return $cached }

    $encoded = [string]$sync.preferences.MinaPortraitPngBase64
    if ([string]::IsNullOrWhiteSpace($encoded)) {
        return $null
    }

    $stream = $null
    try {
        $stream = [IO.MemoryStream]::new([Convert]::FromBase64String($encoded), $false)
        $bitmap = [Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.StreamSource = $stream
        $bitmap.EndInit()
        if ($bitmap.CanFreeze) { $bitmap.Freeze() }
        $sync.RenderedAssetCache['MinaProfileBitmap'] = $bitmap
        return $bitmap
    } catch {
        Write-Warning "Could not load Mina profile portrait: $($_.Exception.Message)"
        return $null
    } finally {
        if ($stream) { $stream.Dispose() }
    }
}
