function New-MinaProfileCard {
    <#
    .SYNOPSIS
        Creates a compact, vertical developer card in the Install sidebar.
        All controls have bounded widths to prevent the category column from
        stealing horizontal space from the application grid.
    #>
    $card = [Windows.Controls.Border]::new()
    $card.Width = 218
    $card.MaxWidth = 218
    $card.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $card.Margin = [Windows.Thickness]::new(4, 10, 4, 4)
    $card.Padding = [Windows.Thickness]::new(11)
    $card.CornerRadius = [Windows.CornerRadius]::new(12)
    $card.BorderThickness = [Windows.Thickness]::new(1)
    $card.SetResourceReference([Windows.Controls.Border]::BorderBrushProperty, 'BorderColor')
    $card.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'MainBackgroundColor')

    $layout = [Windows.Controls.StackPanel]::new()
    $layout.Width = 192
    $layout.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
    $card.Child = $layout

    # Deliberately separate from the original SVG, which remains the window icon.
    $photo = Get-MinaProfileBitmap
    if ($photo) {
        $portrait = [Windows.Controls.Image]::new()
        $portrait.Source = $photo
        $portrait.Width = 132
        $portrait.Height = 132
        $portrait.Stretch = [Windows.Media.Stretch]::UniformToFill
        $portrait.Clip = [Windows.Media.EllipseGeometry]::new(
            [Windows.Point]::new(66, 66), 66, 66
        )
        $portrait.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
        $portrait.Margin = [Windows.Thickness]::new(0, 10, 0, 13)
        $portrait.ToolTip = 'Mina Romany'
        [void]$layout.Children.Add($portrait)
    }

    $details = @(
        @{ Text = 'Mina Romany'; Size = 17; Bold = $true; Margin = 5 },
        @{ Text = 'Developer'; Size = 11; Bold = $false; Margin = 12 },
        @{ Text = '01115842589'; Size = 11.5; Bold = $false; Margin = 5 },
        @{ Text = 'minaromanyofficial@gmail.com'; Size = 10; Bold = $false; Margin = 10 }
    )
    foreach ($detail in $details) {
        $line = [Windows.Controls.TextBlock]::new()
        $line.Text = $detail.Text
        $line.Width = 188
        $line.FontSize = $detail.Size
        $line.TextAlignment = [Windows.TextAlignment]::Center
        $line.TextWrapping = [Windows.TextWrapping]::Wrap
        $line.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
        $line.Margin = [Windows.Thickness]::new(0, 0, 0, $detail.Margin)
        if ($detail.Bold) { $line.FontWeight = [Windows.FontWeights]::Bold }
        $line.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'MainForegroundColor')
        [void]$layout.Children.Add($line)
    }

    $links = @(
        @{ Text = 'minaromany.online'; Url = 'https://minaromany.online' },
        @{ Text = 'Facebook'; Url = 'https://www.facebook.com/MinaRomanyOfficial' },
        @{ Text = 'GitHub'; Url = 'https://github.com/MinaRomanyBoles' },
        @{ Text = 'LinkedIn'; Url = 'https://www.linkedin.com/in/minaromany/' }
    )

    # One button per row. In particular, do NOT use a horizontal WrapPanel
    # (which caused the original category column to grow to ~500 pixels).
    foreach ($link in $links) {
        $button = [Windows.Controls.Button]::new()
        $button.Content = $link.Text
        $button.Tag = $link.Url
        $button.Width = 184
        $button.Height = 27
        $button.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
        $button.Margin = [Windows.Thickness]::new(0, 0, 0, 5)
        $button.Padding = [Windows.Thickness]::new(4, 2, 4, 2)
        $button.FontSize = 11
        $button.ToolTip = $link.Url
        [Windows.Automation.AutomationProperties]::SetName($button, "Open $($link.Text)")
        $button.Add_Click({
            param($sender, $eventArgs)
            Start-Process -FilePath ([string]$sender.Tag)
        })
        [void]$layout.Children.Add($button)
    }

    return $card
}
