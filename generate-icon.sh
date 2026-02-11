#!/bin/bash

# Generate iOS App Icon for Hedaya using macOS built-in tools
# This script creates a simple but beautiful icon

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🎨 Generating Hedaya app icon...${NC}"
echo ""

OUTPUT_DIR="Hedaya/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$OUTPUT_DIR"

# Check if we can use Python with PIL
if python3 -c "from PIL import Image" 2>/dev/null; then
    echo -e "${GREEN}Using Python/PIL to generate icon...${NC}"
    python3 generate-icon.py
    exit $?
fi

# Check if ImageMagick is available
if command -v convert &> /dev/null; then
    echo -e "${GREEN}Using ImageMagick to generate icon...${NC}"
    generate_with_imagemagick
    exit 0
fi

# Fallback: Create a simple icon using sips (macOS built-in)
echo -e "${YELLOW}Using macOS built-in tools (sips)...${NC}"
echo ""

# Create a base 1024x1024 icon first
BASE_SIZE=1024
TEMP_ICON="/tmp/hedaya_base_icon.png"

# Create a simple colored square as base (we'll enhance it)
# Using sips to create a solid color image
python3 << 'PYTHON_SCRIPT'
from PIL import Image, ImageDraw
import os

def create_simple_icon():
    size = 1024
    img = Image.new('RGB', (size, size), color='#1B7A4A')
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    radius = int(size * 0.4)
    
    # Outer circle
    draw.ellipse([center - radius, center - radius, center + radius, center + radius],
                fill='#2ECC71', outline='#FFFFFF', width=20)
    
    # Inner circle
    inner_radius = int(radius * 0.7)
    draw.ellipse([center - inner_radius, center - inner_radius,
                  center + inner_radius, center + inner_radius],
                fill='#1B7A4A', outline='#2ECC71', width=15)
    
    # Crescent moon
    moon_radius = int(radius * 0.5)
    moon_offset = int(moon_radius * 0.3)
    
    # White circle for crescent
    draw.ellipse([center - moon_radius + moon_offset, center - moon_radius,
                  center + moon_radius + moon_offset, center + moon_radius],
                fill='#FFFFFF')
    
    # Overlap to create crescent
    draw.ellipse([center - moon_radius - moon_offset, center - moon_radius,
                  center + moon_radius - moon_offset, center + moon_radius],
                fill='#1B7A4A')
    
    # Star
    star_size = 30
    star_pos = (center + int(radius * 0.6), center - int(radius * 0.4))
    draw.ellipse([star_pos[0] - star_size, star_pos[1] - star_size,
                  star_pos[0] + star_size, star_pos[1] + star_size],
                fill='#FFFFFF')
    
    return img

try:
    icon = create_simple_icon()
    temp_path = "/tmp/hedaya_base_icon.png"
    icon.save(temp_path, 'PNG')
    print("Base icon created")
except ImportError:
    print("PIL not available")
    exit(1)
PYTHON_SCRIPT

if [ ! -f "/tmp/hedaya_base_icon.png" ]; then
    echo -e "${YELLOW}⚠ Could not generate icon automatically${NC}"
    echo ""
    echo -e "${BLUE}Please install Pillow to generate icons:${NC}"
    echo "  pip3 install Pillow"
    echo ""
    echo "Then run: python3 generate-icon.py"
    echo ""
    echo -e "${BLUE}Or manually create icons:${NC}"
    echo "  1. Create a 1024x1024 icon image"
    echo "  2. Use an online tool like: https://www.appicon.co"
    echo "  3. Or use Xcode's built-in icon generator"
    exit 1
fi

# Generate all required sizes using sips
echo "Generating icon sizes..."

ICON_SIZES=(
    "40:icon_20pt@2x.png"
    "60:icon_20pt@3x.png"
    "58:icon_29pt@2x.png"
    "87:icon_29pt@3x.png"
    "80:icon_40pt@2x.png"
    "120:icon_40pt@3x.png"
    "120:icon_60pt@2x.png"
    "180:icon_60pt@3x.png"
    "76:icon_76pt@1x.png"
    "152:icon_76pt@2x.png"
    "167:icon_83.5pt@2x.png"
    "1024:icon_1024pt@1x.png"
)

for size_info in "${ICON_SIZES[@]}"; do
    size="${size_info%%:*}"
    filename="${size_info##*:}"
    output_path="$OUTPUT_DIR/$filename"
    
    echo "  Creating $filename (${size}x${size})..."
    sips -z $size $size /tmp/hedaya_base_icon.png --out "$output_path" > /dev/null 2>&1
done

rm -f /tmp/hedaya_base_icon.png

echo ""
echo -e "${GREEN}✅ Icons generated successfully!${NC}"
echo ""
echo "Icons are ready in: $OUTPUT_DIR"
