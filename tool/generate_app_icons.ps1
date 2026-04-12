$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function New-RoundedRectanglePath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [float]$Radius
    )

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $Radius * 2

    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()

    return $path
}

function Save-PointaIcon {
    param(
        [int]$Size,
        [string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $cardX = [float]($Size * 0.05)
    $cardY = [float]($Size * 0.05)
    $cardWidth = [float]($Size * 0.90)
    $cardHeight = [float]($Size * 0.90)
    $cardRadius = [float]($Size * 0.22)
    $cardRect = [System.Drawing.RectangleF]::new($cardX, $cardY, $cardWidth, $cardHeight)

    $cardPath = New-RoundedRectanglePath -X $cardX -Y $cardY -Width $cardWidth -Height $cardHeight -Radius $cardRadius
    $gradientBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $cardRect,
        [System.Drawing.ColorTranslator]::FromHtml('#1C4DFF'),
        [System.Drawing.ColorTranslator]::FromHtml('#6F5DFF'),
        45.0
    )
    $graphics.FillPath($gradientBrush, $cardPath)

    $highlightBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(40, 255, 255, 255))
    $graphics.FillEllipse(
        $highlightBrush,
        [float]($Size * 0.18),
        [float]($Size * 0.14),
        [float]($Size * 0.46),
        [float]($Size * 0.26)
    )

    $fontFamily = [System.Drawing.FontFamily]::new('Segoe UI')
    $font = [System.Drawing.Font]::new(
        $fontFamily,
        [float]($Size * 0.52),
        [System.Drawing.FontStyle]::Bold,
        [System.Drawing.GraphicsUnit]::Pixel
    )
    $textBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(250, 255, 255, 255))
    $stringFormat = [System.Drawing.StringFormat]::new()
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    $textRect = [System.Drawing.RectangleF]::new(
        0,
        [float](-($Size * 0.03)),
        [float]$Size,
        [float]$Size
    )
    $graphics.DrawString('P', $font, $textBrush, $textRect, $stringFormat)

    $dotBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#8CE6FF'))
    $graphics.FillEllipse(
        $dotBrush,
        [float]($Size * 0.64),
        [float]($Size * 0.68),
        [float]($Size * 0.12),
        [float]($Size * 0.12)
    )

    $outlinePen = [System.Drawing.Pen]::new(
        [System.Drawing.Color]::FromArgb(24, 255, 255, 255),
        [float]([Math]::Max(2, $Size * 0.012))
    )
    $graphics.DrawPath($outlinePen, $cardPath)

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

    $outlinePen.Dispose()
    $dotBrush.Dispose()
    $stringFormat.Dispose()
    $textBrush.Dispose()
    $font.Dispose()
    $fontFamily.Dispose()
    $highlightBrush.Dispose()
    $gradientBrush.Dispose()
    $cardPath.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$projectRoot = Split-Path -Parent $PSScriptRoot

$stagingRoot = Join-Path $projectRoot 'assets/branding/generated'
if (-not (Test-Path $stagingRoot)) {
    New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null
}

$targets = @(
    @{ Size = 48; Name = 'android-mipmap-mdpi.png' },
    @{ Size = 72; Name = 'android-mipmap-hdpi.png' },
    @{ Size = 96; Name = 'android-mipmap-xhdpi.png' },
    @{ Size = 144; Name = 'android-mipmap-xxhdpi.png' },
    @{ Size = 192; Name = 'android-mipmap-xxxhdpi.png' },
    @{ Size = 20; Name = 'ios-Icon-App-20x20@1x.png' },
    @{ Size = 40; Name = 'ios-Icon-App-20x20@2x.png' },
    @{ Size = 60; Name = 'ios-Icon-App-20x20@3x.png' },
    @{ Size = 29; Name = 'ios-Icon-App-29x29@1x.png' },
    @{ Size = 58; Name = 'ios-Icon-App-29x29@2x.png' },
    @{ Size = 87; Name = 'ios-Icon-App-29x29@3x.png' },
    @{ Size = 40; Name = 'ios-Icon-App-40x40@1x.png' },
    @{ Size = 80; Name = 'ios-Icon-App-40x40@2x.png' },
    @{ Size = 120; Name = 'ios-Icon-App-40x40@3x.png' },
    @{ Size = 120; Name = 'ios-Icon-App-60x60@2x.png' },
    @{ Size = 180; Name = 'ios-Icon-App-60x60@3x.png' },
    @{ Size = 76; Name = 'ios-Icon-App-76x76@1x.png' },
    @{ Size = 152; Name = 'ios-Icon-App-76x76@2x.png' },
    @{ Size = 167; Name = 'ios-Icon-App-83.5x83.5@2x.png' },
    @{ Size = 1024; Name = 'ios-Icon-App-1024x1024@1x.png' }
)

foreach ($target in $targets) {
    $stagingPath = Join-Path $stagingRoot $target.Name
    Save-PointaIcon -Size $target.Size -Path $stagingPath
}

Write-Host 'Pointa staging app icons generated.'
