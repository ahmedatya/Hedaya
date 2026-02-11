#!/usr/bin/env python3
"""
Generate iOS App Icon for Hedaya
Creates all required icon sizes for iOS
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
except ImportError as e:
    print(f"PIL/Pillow is required. Install it with: pip3 install Pillow")
    print(f"Error: {e}")
    exit(1)

# Icon sizes required for iOS App Icon
ICON_SIZES = [
    (20, 20, 2),      # 20pt @2x
    (20, 20, 3),      # 20pt @3x
    (29, 29, 2),      # 29pt @2x
    (29, 29, 3),      # 29pt @3x
    (40, 40, 2),      # 40pt @2x
    (40, 40, 3),      # 40pt @3x
    (60, 60, 2),      # 60pt @2x
    (60, 60, 3),      # 60pt @3x
    (76, 76, 1),      # 76pt @1x (iPad)
    (76, 76, 2),      # 76pt @2x (iPad)
    (83.5, 83.5, 2),  # 83.5pt @2x (iPad Pro)
    (1024, 1024, 1),  # App Store
]

def create_icon(size, scale):
    """Create an icon with the given size and scale"""
    width, height = int(size * scale), int(size * scale)
    
    # Create image with gradient background
    img = Image.new('RGB', (width, height), color='#1B7A4A')
    draw = ImageDraw.Draw(img)
    
    # Draw gradient background (simplified - solid color with circle)
    center = (width // 2, height // 2)
    radius = int(width * 0.4)
    
    # Draw outer circle (lighter green)
    draw.ellipse(
        [center[0] - radius, center[1] - radius, 
         center[0] + radius, center[1] + radius],
        fill='#2ECC71',
        outline='#FFFFFF',
        width=max(2, int(width * 0.02))
    )
    
    # Draw inner circle (darker green)
    inner_radius = int(radius * 0.7)
    draw.ellipse(
        [center[0] - inner_radius, center[1] - inner_radius,
         center[0] + inner_radius, center[1] + inner_radius],
        fill='#1B7A4A',
        outline='#2ECC71',
        width=max(1, int(width * 0.015))
    )
    
    # Draw crescent moon (simplified as a white arc)
    if width >= 60:  # Only draw details for larger icons
        # Draw crescent shape
        moon_radius = int(radius * 0.5)
        moon_offset = int(moon_radius * 0.3)
        
        # Draw white crescent
        draw.ellipse(
            [center[0] - moon_radius + moon_offset, center[1] - moon_radius,
             center[0] + moon_radius + moon_offset, center[1] + moon_radius],
            fill='#FFFFFF',
            outline=None
        )
        
        # Draw overlapping circle to create crescent shape
        draw.ellipse(
            [center[0] - moon_radius - moon_offset, center[1] - moon_radius,
             center[0] + moon_radius - moon_offset, center[1] + moon_radius],
            fill='#1B7A4A',
            outline=None
        )
    
    # Add star (small white dot) for larger icons
    if width >= 120:
        star_size = max(3, int(width * 0.03))
        star_pos = (center[0] + int(radius * 0.6), center[1] - int(radius * 0.4))
        draw.ellipse(
            [star_pos[0] - star_size, star_pos[1] - star_size,
             star_pos[0] + star_size, star_pos[1] + star_size],
            fill='#FFFFFF'
        )
    
    return img

def main():
    """Generate all icon sizes"""
    output_dir = "Hedaya/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    
    print("🎨 Generating Hedaya app icons...")
    print("")
    
    icons_generated = []
    
    for size, _, scale in ICON_SIZES:
        actual_size = int(size * scale)
        filename = f"icon_{size}pt@{scale}x.png"
        filepath = os.path.join(output_dir, filename)
        
        print(f"  Creating {filename} ({actual_size}x{actual_size})...")
        icon = create_icon(size, scale)
        icon.save(filepath, 'PNG')
        icons_generated.append((size, scale, filename))
    
    print("")
    print("✅ Icons generated successfully!")
    print("")
    print("Generated files:")
    for size, scale, filename in icons_generated:
        print(f"  - {filename}")
    
    print("")
    print("📱 Next steps:")
    print("  1. Open Hedaya.xcodeproj in Xcode")
    print("  2. Go to Assets.xcassets → AppIcon")
    print("  3. Drag the generated icons to their respective slots")
    print("")
    print("Or the icons are ready to use in the AppIcon.appiconset folder!")

if __name__ == "__main__":
    main()
