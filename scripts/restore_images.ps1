$backup='C:\Users\jhigg\Downloads\CreationsofAA_v2\products_backup_20260626_120841'
$dst='C:\Users\jhigg\Downloads\CreationsofAA_v2\products'
$files=@('expansions.png','keiper.png','cerulean.png','aligned.png','AA-collectable.png','life.png','emerald-glow.png','mystic-drop.png')
foreach($f in $files){
    $src=Join-Path $backup $f
    if(Test-Path $src){
        Copy-Item -Path $src -Destination (Join-Path $dst $f) -Force
        Write-Output "Restored: $f"
    } else {
        Write-Output "Missing in backup: $f"
    }
}
