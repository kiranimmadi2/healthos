$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$primary = [System.Drawing.Color]::FromArgb(255, 37, 99, 235)
$teal = [System.Drawing.Color]::FromArgb(255, 20, 184, 166)
$white = [System.Drawing.Color]::White

function New-RoundedRectanglePath {
  param(
    [System.Drawing.RectangleF]$Rectangle,
    [float]$Radius
  )

  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $diameter = $Radius * 2
  $arc = [System.Drawing.RectangleF]::new(
    $Rectangle.X,
    $Rectangle.Y,
    $diameter,
    $diameter
  )
  $path.AddArc($arc, 180, 90)
  $arc.X = $Rectangle.Right - $diameter
  $path.AddArc($arc, 270, 90)
  $arc.Y = $Rectangle.Bottom - $diameter
  $path.AddArc($arc, 0, 90)
  $arc.X = $Rectangle.X
  $path.AddArc($arc, 90, 90)
  $path.CloseFigure()
  return $path
}

function New-HealthOsBitmap {
  param(
    [int]$Size,
    [bool]$RoundedBackground = $true,
    [bool]$ForegroundOnly = $false
  )

  $bitmap = [System.Drawing.Bitmap]::new(
    $Size,
    $Size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.CompositingQuality =
    [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.Clear([System.Drawing.Color]::Transparent)

  $scale = $Size / 1024.0

  if (-not $ForegroundOnly) {
    $backgroundBrush = [System.Drawing.SolidBrush]::new($primary)
    if ($RoundedBackground) {
      $backgroundPath = New-RoundedRectanglePath `
        ([System.Drawing.RectangleF]::new(0, 0, $Size, $Size)) `
        (220 * $scale)
      $graphics.FillPath($backgroundBrush, $backgroundPath)
      $backgroundPath.Dispose()
    } else {
      $graphics.FillRectangle($backgroundBrush, 0, 0, $Size, $Size)
    }
    $backgroundBrush.Dispose()
  }

  $shieldPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $shieldPath.StartFigure()
  $shieldPath.AddLine(512 * $scale, 150 * $scale, 780 * $scale, 260 * $scale)
  $shieldPath.AddLine(780 * $scale, 260 * $scale, 780 * $scale, 450 * $scale)
  $shieldPath.AddBezier(
    780 * $scale, 450 * $scale,
    780 * $scale, 610 * $scale,
    690 * $scale, 775 * $scale,
    512 * $scale, 870 * $scale
  )
  $shieldPath.AddBezier(
    512 * $scale, 870 * $scale,
    334 * $scale, 775 * $scale,
    244 * $scale, 610 * $scale,
    244 * $scale, 450 * $scale
  )
  $shieldPath.AddLine(244 * $scale, 450 * $scale, 244 * $scale, 260 * $scale)
  $shieldPath.CloseFigure()

  $whiteBrush = [System.Drawing.SolidBrush]::new($white)
  $graphics.FillPath($whiteBrush, $shieldPath)

  $blueBrush = [System.Drawing.SolidBrush]::new($primary)
  $graphics.FillRectangle(
    $blueBrush,
    448 * $scale,
    330 * $scale,
    128 * $scale,
    360 * $scale
  )
  $graphics.FillRectangle(
    $blueBrush,
    332 * $scale,
    446 * $scale,
    360 * $scale,
    128 * $scale
  )

  $tealBrush = [System.Drawing.SolidBrush]::new($teal)
  $graphics.FillEllipse(
    $tealBrush,
    650 * $scale,
    650 * $scale,
    210 * $scale,
    210 * $scale
  )

  $checkPen = [System.Drawing.Pen]::new($white, [Math]::Max(2, 34 * $scale))
  $checkPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $checkPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $checkPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $graphics.DrawLines(
    $checkPen,
    [System.Drawing.PointF[]]@(
      [System.Drawing.PointF]::new(700 * $scale, 752 * $scale),
      [System.Drawing.PointF]::new(748 * $scale, 800 * $scale),
      [System.Drawing.PointF]::new(820 * $scale, 712 * $scale)
    )
  )

  $checkPen.Dispose()
  $tealBrush.Dispose()
  $blueBrush.Dispose()
  $whiteBrush.Dispose()
  $shieldPath.Dispose()
  $graphics.Dispose()
  return $bitmap
}

function Save-HealthOsPng {
  param(
    [int]$Size,
    [string]$Path,
    [bool]$RoundedBackground = $true,
    [bool]$ForegroundOnly = $false,
    [bool]$OpaqueOutput = $false
  )

  $directory = Split-Path $Path -Parent
  New-Item -ItemType Directory -Force -Path $directory | Out-Null
  $bitmap = New-HealthOsBitmap $Size $RoundedBackground $ForegroundOnly
  if ($OpaqueOutput) {
    $opaqueBitmap = [System.Drawing.Bitmap]::new(
      $Size,
      $Size,
      [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $opaqueGraphics = [System.Drawing.Graphics]::FromImage($opaqueBitmap)
    $opaqueGraphics.DrawImage($bitmap, 0, 0, $Size, $Size)
    $opaqueGraphics.Dispose()
    $opaqueBitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $opaqueBitmap.Dispose()
  } else {
    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  $bitmap.Dispose()
}

function Save-MultiSizeIco {
  param(
    [int[]]$Sizes,
    [string]$Path
  )

  $images = @()
  foreach ($size in $Sizes) {
    $bitmap = New-HealthOsBitmap $size $true $false
    $stream = [System.IO.MemoryStream]::new()
    $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    $images += ,@($size, $stream.ToArray())
    $stream.Dispose()
    $bitmap.Dispose()
  }

  New-Item -ItemType Directory -Force -Path (Split-Path $Path -Parent) |
    Out-Null
  $file = [System.IO.File]::Open(
    $Path,
    [System.IO.FileMode]::Create,
    [System.IO.FileAccess]::Write
  )
  $writer = [System.IO.BinaryWriter]::new($file)
  $writer.Write([UInt16]0)
  $writer.Write([UInt16]1)
  $writer.Write([UInt16]$images.Count)

  $offset = 6 + (16 * $images.Count)
  foreach ($image in $images) {
    $size = [int]$image[0]
    $bytes = [byte[]]$image[1]
    $dimension = if ($size -ge 256) { 0 } else { $size }
    $writer.Write([byte]$dimension)
    $writer.Write([byte]$dimension)
    $writer.Write([byte]0)
    $writer.Write([byte]0)
    $writer.Write([UInt16]1)
    $writer.Write([UInt16]32)
    $writer.Write([UInt32]$bytes.Length)
    $writer.Write([UInt32]$offset)
    $offset += $bytes.Length
  }

  foreach ($image in $images) {
    $writer.Write([byte[]]$image[1])
  }
  $writer.Dispose()
  $file.Dispose()
}

# Master asset used inside the Flutter UI.
Save-HealthOsPng 1024 "$root\assets\branding\healthos_app_icon.png"

# Android legacy and adaptive launcher icons.
$androidSizes = @{
  "mipmap-mdpi" = 48
  "mipmap-hdpi" = 72
  "mipmap-xhdpi" = 96
  "mipmap-xxhdpi" = 144
  "mipmap-xxxhdpi" = 192
}
$androidForegroundSizes = @{
  "mipmap-mdpi" = 108
  "mipmap-hdpi" = 162
  "mipmap-xhdpi" = 216
  "mipmap-xxhdpi" = 324
  "mipmap-xxxhdpi" = 432
}
foreach ($entry in $androidSizes.GetEnumerator()) {
  Save-HealthOsPng `
    $entry.Value `
    "$root\android\app\src\main\res\$($entry.Key)\ic_launcher.png"
}
foreach ($entry in $androidForegroundSizes.GetEnumerator()) {
  Save-HealthOsPng `
    $entry.Value `
    "$root\android\app\src\main\res\$($entry.Key)\ic_launcher_foreground.png" `
    $false `
    $true
}
Save-HealthOsPng `
  192 `
  "$root\android\app\src\main\res\drawable-nodpi\launch_image.png"

# iOS launcher and splash icons.
$iosIcons = @{
  "Icon-App-20x20@1x.png" = 20
  "Icon-App-20x20@2x.png" = 40
  "Icon-App-20x20@3x.png" = 60
  "Icon-App-29x29@1x.png" = 29
  "Icon-App-29x29@2x.png" = 58
  "Icon-App-29x29@3x.png" = 87
  "Icon-App-40x40@1x.png" = 40
  "Icon-App-40x40@2x.png" = 80
  "Icon-App-40x40@3x.png" = 120
  "Icon-App-60x60@2x.png" = 120
  "Icon-App-60x60@3x.png" = 180
  "Icon-App-76x76@1x.png" = 76
  "Icon-App-76x76@2x.png" = 152
  "Icon-App-83.5x83.5@2x.png" = 167
  "Icon-App-1024x1024@1x.png" = 1024
}
$iosDirectory = "$root\ios\Runner\Assets.xcassets\AppIcon.appiconset"
foreach ($entry in $iosIcons.GetEnumerator()) {
  Save-HealthOsPng `
    $entry.Value `
    "$iosDirectory\$($entry.Key)" `
    $false `
    $false `
    $true
}
$launchDirectory = "$root\ios\Runner\Assets.xcassets\LaunchImage.imageset"
Save-HealthOsPng 120 "$launchDirectory\LaunchImage.png"
Save-HealthOsPng 240 "$launchDirectory\LaunchImage@2x.png"
Save-HealthOsPng 360 "$launchDirectory\LaunchImage@3x.png"

# macOS launcher icons.
foreach ($size in @(16, 32, 64, 128, 256, 512, 1024)) {
  Save-HealthOsPng `
    $size `
    "$root\macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_$size.png"
}

# Windows executable icon.
Save-MultiSizeIco `
  @(16, 24, 32, 48, 64, 128, 256) `
  "$root\windows\runner\resources\app_icon.ico"

# Linux bundle icon.
Save-HealthOsPng 256 "$root\linux\runner\resources\healthos.png"

# Web and installable PWA icons.
Save-HealthOsPng 32 "$root\web\favicon.png"
Save-HealthOsPng 192 "$root\web\icons\Icon-192.png"
Save-HealthOsPng 512 "$root\web\icons\Icon-512.png"
Save-HealthOsPng 192 "$root\web\icons\Icon-maskable-192.png" $false
Save-HealthOsPng 512 "$root\web\icons\Icon-maskable-512.png" $false

Write-Output "Generated HealthOS icons for Android, iOS, web, Windows, macOS, and Linux."
