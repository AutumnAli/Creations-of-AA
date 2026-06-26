from PIL import Image
from pathlib import Path

src_dir = Path(r"c:\Users\jhigg\Downloads\CreationsofAA_v2\products")
target_size = (689, 934)

for p in src_dir.glob('*.png'):
    img = Image.open(p).convert('RGBA')
    img.thumbnail((target_size[0], target_size[1]), Image.LANCZOS)
    # create transparent background
    background = Image.new('RGBA', target_size, (255,255,255,0))
    # center
    x = (target_size[0] - img.width) // 2
    y = (target_size[1] - img.height) // 2
    background.paste(img, (x,y), img)
    out_path = src_dir / p.name
    background.save(out_path)
    print(f"Resized {p.name} -> {target_size}")
