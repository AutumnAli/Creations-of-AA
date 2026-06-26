Param(
    [string]$Folder = "C:\Users\jhigg\Downloads\CreationsofAA_v2\products",
    [int]$TargetW = 689,
    [int]$TargetH = 934
)

$dt = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $Folder "..\products_backup_$dt"
New-Item -ItemType Directory -Path $backup | Out-Null
Get-ChildItem -Path $Folder -Filter *.png | ForEach-Object { Copy-Item $_.FullName -Destination $backup }
Write-Output "Backup created at: $backup"

Add-Type -AssemblyName System.Drawing

Get-ChildItem -Path $Folder -Filter *.png | ForEach-Object {
    $path = $_.FullName
    $img = [System.Drawing.Image]::FromFile($path)
    $w = $img.Width; $h = $img.Height

    # Sample four corner pixels to estimate background color
    $bmpSrc = New-Object System.Drawing.Bitmap $img
    $c1 = $bmpSrc.GetPixel(0,0)
    $c2 = $bmpSrc.GetPixel([Math]::Max(0,$w-1),0)
    $c3 = $bmpSrc.GetPixel(0,[Math]::Max(0,$h-1))
    $c4 = $bmpSrc.GetPixel([Math]::Max(0,$w-1),[Math]::Max(0,$h-1))

    $avgR = [int](([int]$c1.R + [int]$c2.R + [int]$c3.R + [int]$c4.R) / 4)
    $avgG = [int](([int]$c1.G + [int]$c2.G + [int]$c3.G + [int]$c4.G) / 4)
    $avgB = [int](([int]$c1.B + [int]$c2.B + [int]$c3.B + [int]$c4.B) / 4)

    $bgColor = [System.Drawing.Color]::FromArgb(255,$avgR,$avgG,$avgB)

    # compute resize
    $ratio = [System.Math]::Min($TargetW / [double]$w, $TargetH / [double]$h)
    $newW = [int]([System.Math]::Round($w * $ratio))
    $newH = [int]([System.Math]::Round($h * $ratio))

    $bmp = New-Object System.Drawing.Bitmap $TargetW, $TargetH
    $bmp.SetResolution($img.HorizontalResolution, $img.VerticalResolution)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear($bgColor)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    $x = [int](($TargetW - $newW) / 2)
    $y = [int](($TargetH - $newH) / 2)
    $g.DrawImage($img, $x, $y, $newW, $newH)

    $img.Dispose()
    $bmpSrc.Dispose()
    $g.Dispose()

    $encoder = [System.Drawing.Imaging.ImageFormat]::Png
    $bmp.Save($path, $encoder)
    $bmp.Dispose()

    Write-Output "Processed: $($_.Name) -> ${TargetW}x${TargetH} with bg rgb($avgR,$avgG,$avgB)"
}
