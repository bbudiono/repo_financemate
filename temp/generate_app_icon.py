from PIL import Image, ImageDraw, ImageFont
import os

# Icon parameters
size = 1024
bg_gradient_start = (34, 193, 195)
bg_gradient_end = (255, 255, 255)
text = "FM"
text_color = (255, 255, 255, 230)
font_size = 420
output_path = "_macOS/FinanceMate/FinanceMate/Assets.xcassets/AppIcon.appiconset/FinanceMate_AppStoreIcon.png"

# Create gradient background
img = Image.new('RGBA', (size, size), bg_gradient_start)
draw = ImageDraw.Draw(img)
for y in range(size):
    r = bg_gradient_start[0] + (bg_gradient_end[0] - bg_gradient_start[0]) * y // size
    g = bg_gradient_start[1] + (bg_gradient_end[1] - bg_gradient_start[1]) * y // size
    b = bg_gradient_start[2] + (bg_gradient_end[2] - bg_gradient_start[2]) * y // size
    draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

# Draw rounded corners
corner_radius = 180
mask = Image.new('L', (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
img.putalpha(mask)

# Draw text
try:
    font = ImageFont.truetype('/Library/Fonts/Arial Bold.ttf', font_size)
except:
    font = ImageFont.load_default()
    font_size = 200
# Use getbbox for accurate text size in Pillow >=8.0
try:
    bbox = font.getbbox(text)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
except AttributeError:
    w, h = font.getsize(text)
draw.text(((size-w)//2, (size-h)//2-60), text, font=font, fill=text_color)

# Save icon
os.makedirs(os.path.dirname(output_path), exist_ok=True)
img.save(output_path)
print(f"Icon saved to {output_path}") 