Param(
    [string]$Folder = "C:\Users\jhigg\Downloads\CreationsofAA_v2\products",
    [int]$TargetW = 689,
    [int]$TargetH = 934
)

Add-Type -AssemblyName System.Drawing

Get-ChildItem -Path $Folder -Filter *.png | ForEach-Object {
    $path = $_.FullName
    $img = [System.Drawing.Image]::FromFile($path)

    $ratio = [System.Math]::Min($TargetW / [double]$img.Width, $TargetH / [double]$img.Height)
    $newW = [int]([System.Math]::Round($img.Width * $ratio))
    $newH = [int]([System.Math]::Round($img.Height * $ratio))

    $bmp = New-Object System.Drawing.Bitmap $TargetW, $TargetH
    $bmp.SetResolution($img.HorizontalResolution, $img.VerticalResolution)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    $x = [int](($TargetW - $newW) / 2)
    $y = [int](($TargetH - $newH) / 2)

    $g.DrawImage($img, $x, $y, $newW, $newH)

    $img.Dispose()
    $g.Dispose()

    $encoder = [System.Drawing.Imaging.ImageFormat]::Png
    $bmp.Save($path, $encoder)
    $bmp.Dispose()

    Write-Output "Resized: $($_.Name) -> ${TargetW}x${TargetH}"
}
