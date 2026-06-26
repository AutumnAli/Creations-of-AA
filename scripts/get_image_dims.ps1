param([string]$path)
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($path)
Write-Output "$($img.Width),$($img.Height)"
$img.Dispose()
