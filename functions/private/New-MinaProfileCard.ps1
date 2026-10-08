function New-MinaProfileCard {
    <#
    .SYNOPSIS
        Builds the small developer card in the Install sidebar.
        The social buttons launch only the three explicitly configured pages.
    #>
    $card = [Windows.Controls.Border]::new()
    $card.Margin = [Windows.Thickness]::new(4, 8, 4, 4)
    $card.Padding = [Windows.Thickness]::new(8)
    $card.BorderThickness = [Windows.Thickness]::new(1)
    $card.CornerRadius = [Windows.CornerRadius]::new(8)
    $card.SetResourceReference([Windows.Controls.Border]::BorderBrushProperty, 'BorderColor')
    $card.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'MainBackgroundColor')

    $layout = [Windows.Controls.StackPanel]::new()
    $layout.HorizontalAlignment = [Windows.HorizontalAlignment]::Stretch
    $card.Child = $layout

    $portrait = [Windows.Controls.Image]::new()
    $portrait.Width = 92
    $portrait.Height = 76
    $portrait.Stretch = [Windows.Media.Stretch]::Uniform
    $portrait.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
    $portrait.Margin = [Windows.Thickness]::new(0, 4, 0, 8)
    $portrait.Source = Get-MinaBrandBitmap
    if ($portrait.Source) {
        [void]$layout.Children.Add($portrait)
    }

    $details = @(
        @{ Text = 'Mina Romany'; Bold = $true; Size = 15 },
        @{ Text = '01115842589'; Bold = $false; Size = 12 },
        @{ Text = 'minaromanyofficial@gmail.com'; Bold = $false; Size = 10.5 }
    )
    foreach ($detail in $details) {
        $line = [Windows.Controls.TextBlock]::new()
        $line.Text = $detail.Text
        $line.TextAlignment = [Windows.TextAlignment]::Center
        $line.TextWrapping = [Windows.TextWrapping]::WrapWithOverflow
        $line.HorizontalAlignment = [Windows.HorizontalAlignment]::Stretch
        $line.Margin = [Windows.Thickness]::new(0, 0, 0, 5)
        $line.FontSize = $detail.Size
        if ($detail.Bold) {
            $line.FontWeight = [Windows.FontWeights]::Bold
        }
        $line.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'MainForegroundColor')
        [void]$layout.Children.Add($line)
    }

    # The website is an actual clickable text button, not a non-functional label.
    $website = [Windows.Controls.Button]::new()
    $website.Content = 'minaromany.online'
    $website.Tag = 'https://minaromany.online'
    $website.Margin = [Windows.Thickness]::new(0, 2, 0, 6)
    $website.FontSize = 11
    $website.ToolTip = 'Open https://minaromany.online'
    $website.Add_Click({
        param($sender, $eventArgs)
        Start-Process -FilePath ([string]$sender.Tag)
    })
    [void]$layout.Children.Add($website)

    $socialRow = [Windows.Controls.WrapPanel]::new()
    $socialRow.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
    $socialRow.Orientation = [Windows.Controls.Orientation]::Horizontal

    $socialLinks = @(
        @{ Text = 'Facebook'; Url = 'https://www.facebook.com/MinaRomanyOfficial' },
        @{ Text = 'GitHub'; Url = 'https://github.com/MinaRomanyBoles' },
        @{ Text = 'LinkedIn'; Url = 'https://www.linkedin.com/in/minaromany/' }
    )
    foreach ($item in $socialLinks) {
        $button = [Windows.Controls.Button]::new()
        $button.Content = $item.Text
        $button.Tag = $item.Url
        $button.FontSize = 11
        $button.Padding = [Windows.Thickness]::new(5, 4, 5, 4)
        $button.Margin = [Windows.Thickness]::new(2, 2, 2, 2)
        $button.ToolTip = $item.Url
        [Windows.Automation.AutomationProperties]::SetName($button, "Open $($item.Text)")
        $button.Add_Click({
            param($sender, $eventArgs)
            Start-Process -FilePath ([string]$sender.Tag)
        })
        [void]$socialRow.Children.Add($button)
    }
    [void]$layout.Children.Add($socialRow)

    return $card
}
