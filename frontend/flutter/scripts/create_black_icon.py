#!/usr/bin/env python3
"""
Tamamen siyah ikon oluşturucu
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_black_icon(size, output_path):
    """Tamamen siyah ikon oluştur - hiç beyaz kaplama yok"""
    # Tamamen siyah arka plan - hiç beyaz daire yok
    img = Image.new('RGB', (size, size), color='black')
    
    # Dosyayı kaydet
    img.save(output_path)
    print(f"Created {output_path} ({size}x{size}) - pure black, no white circle")

def main():
    # Android için gerekli boyutlar
    android_sizes = [
        (48, "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
        (72, "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
        (96, "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
        (144, "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
        (192, "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
    ]
    
    # iOS için gerekli boyutlar
    ios_sizes = [
        (20, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png"),
        (40, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png"),
        (60, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png"),
        (29, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png"),
        (58, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png"),
        (87, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png"),
        (40, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png"),
        (80, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png"),
        (120, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png"),
        (120, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png"),
        (180, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png"),
        (76, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png"),
        (152, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png"),
        (167, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png"),
        (1024, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"),
    ]
    
    # Android ikonları oluştur
    for size, path in android_sizes:
        create_black_icon(size, path)
    
    # iOS ikonları oluştur
    for size, path in ios_sizes:
        create_black_icon(size, path)
    
    print("All black icons created successfully!")

if __name__ == "__main__":
    main()