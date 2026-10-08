function Get-MinaBrandBitmap {
    <#
    .SYNOPSIS
        Returns the PNG raster of Mina's supplied SVG, embedded by Compile.ps1.
        The image is frozen so it can be shared safely across WPF runspaces.
    #>
    if ($sync.RenderedAssetCache['MinaBrandBitmap']) {
        return $sync.RenderedAssetCache['MinaBrandBitmap']
    }

    if ([string]::IsNullOrWhiteSpace([string]$sync.preferences.MinaBrandPngBase64)) {
        return $null
    }

    $stream = $null
    try {
        $pngBytes = [Convert]::FromBase64String([string]$sync.preferences.MinaBrandPngBase64)
        $stream = [IO.MemoryStream]::new($pngBytes, $false)
        $bitmap = [Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.StreamSource = $stream
        $bitmap.EndInit()
        if ($bitmap.CanFreeze) {
            $bitmap.Freeze()
        }
        $sync.RenderedAssetCache['MinaBrandBitmap'] = $bitmap
        return $bitmap
    } catch {
        Write-Warning "Unable to load the embedded Mina logo: $($_.Exception.Message)"
        return $null
    } finally {
        if ($null -ne $stream) {
            $stream.Dispose()
        }
    }
}
