import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_app_icon(size=1024):
    scale = 2
    S = size * scale  # 2048x2048 canvas for super-sampling

    img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Base Squircle Shape with Gradient
    margin = int(S * 0.05)
    r = int(S * 0.24)
    box = [margin, margin, S - margin, S - margin]

    # Create mask for rounded rectangle
    mask = Image.new('L', (S, S), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(box, radius=r, fill=255)

    # Luxury Gradient Background (Royal Deep Emerald)
    # from (12, 45, 30) at top-left to (5, 18, 12) at bottom-right
    bg = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(S):
        factor = y / S
        # Smooth interpolation
        r_c = int(14 * (1 - factor * 0.7) + 6 * (factor * 0.7))
        g_c = int(52 * (1 - factor * 0.65) + 20 * (factor * 0.65))
        b_c = int(36 * (1 - factor * 0.65) + 14 * (factor * 0.65))
        bg_draw.line([(0, y), (S, y)], fill=(r_c, g_c, b_c, 255))

    # Add radial specular highlight at top center
    specular = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    spec_draw = ImageDraw.Draw(specular)
    center_x, center_y = S // 2, int(S * 0.25)
    max_rad = int(S * 0.6)
    for rad in range(max_rad, 0, -8):
        alpha = int(35 * (1 - rad / max_rad))
        spec_draw.ellipse([center_x - rad, center_y - rad, center_x + rad, center_y + rad], fill=(22, 163, 74, alpha))
    
    bg = Image.alpha_composite(bg, specular)

    # Apply rounded mask
    rounded_bg = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    rounded_bg.paste(bg, (0, 0), mask=mask)

    # Gold rim border
    border_img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_img)
    border_draw.rounded_rectangle(box, radius=r, outline=(212, 175, 55, 180), width=int(S * 0.012))
    # Inner subtle rim
    inner_box = [margin + 8, margin + 8, S - margin - 8, S - margin - 8]
    border_draw.rounded_rectangle(inner_box, radius=r - 6, outline=(245, 208, 97, 80), width=int(S * 0.005))
    
    rounded_bg = Image.alpha_composite(rounded_bg, border_img)

    # 2. Central Symbol Emblem: "W" Monogram + Store Canopy + Diamond Spark
    symbol_img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    sym_draw = ImageDraw.Draw(symbol_img)

    cx = S / 2.0
    cy = S / 2.0 + (S * 0.02)  # slightly lowered to balance the crown

    # Outer W points
    w_width = S * 0.58
    w_height = S * 0.44

    left_x = cx - w_width / 2.0
    right_x = cx + w_width / 2.0
    top_y = cy - w_height / 2.0
    bottom_y = cy + w_height / 2.0

    stem_thick = S * 0.082

    # Draw the dynamic modern W with geometric faceted polygons
    # Left Outer Stem (Emerald-White metallic)
    p_left_stem = [
        (left_x, top_y + S * 0.03),
        (left_x + stem_thick, top_y),
        (cx - w_width * 0.22 + stem_thick * 0.6, bottom_y),
        (cx - w_width * 0.22 - stem_thick * 0.4, bottom_y),
    ]
    sym_draw.polygon(p_left_stem, fill=(255, 255, 255, 245))

    # Right Outer Stem (Symmetrical)
    p_right_stem = [
        (right_x, top_y + S * 0.03),
        (right_x - stem_thick, top_y),
        (cx + w_width * 0.22 - stem_thick * 0.6, bottom_y),
        (cx + w_width * 0.22 + stem_thick * 0.4, bottom_y),
    ]
    sym_draw.polygon(p_right_stem, fill=(255, 255, 255, 245))

    # Left Inner Diagonal (meeting at apex)
    p_left_inner = [
        (cx - w_width * 0.22 - stem_thick * 0.4, bottom_y),
        (cx - w_width * 0.22 + stem_thick * 0.6, bottom_y),
        (cx, top_y + S * 0.07),
        (cx - stem_thick * 0.7, top_y + S * 0.07 + stem_thick),
    ]
    sym_draw.polygon(p_left_inner, fill=(225, 235, 230, 230))

    # Right Inner Diagonal (Gold Facet Accent!)
    p_right_inner = [
        (cx + w_width * 0.22 + stem_thick * 0.4, bottom_y),
        (cx + w_width * 0.22 - stem_thick * 0.6, bottom_y),
        (cx, top_y + S * 0.07),
        (cx + stem_thick * 0.7, top_y + S * 0.07 + stem_thick),
    ]
    sym_draw.polygon(p_right_inner, fill=(245, 208, 97, 245))

    # Gold Storefront Canopy / Crown over center apex
    canopy_w = S * 0.24
    canopy_h = S * 0.12
    canopy_y = top_y - S * 0.04
    
    # Diamond / Gem emblem at the top center
    diamond_h = S * 0.09
    diamond_w = S * 0.09
    p_diamond = [
        (cx, canopy_y - diamond_h),
        (cx + diamond_w / 2, canopy_y - diamond_h / 2),
        (cx, canopy_y),
        (cx - diamond_w / 2, canopy_y - diamond_h / 2),
    ]
    sym_draw.polygon(p_diamond, fill=(250, 218, 122, 255))
    
    # Inner bright facet of diamond
    p_diamond_inner = [
        (cx, canopy_y - diamond_h + 8),
        (cx + diamond_w / 2 - 8, canopy_y - diamond_h / 2),
        (cx, canopy_y - 8),
    ]
    sym_draw.polygon(p_diamond_inner, fill=(255, 245, 195, 255))

    # 3 Storefront Awning Ribs in Gold Gradient above the W
    rib_width = S * 0.06
    rib_height = S * 0.045
    rib_y = top_y + S * 0.015

    # Center Canopy Chevron
    p_chevron = [
        (cx - canopy_w * 0.65, rib_y + rib_height),
        (cx, rib_y - rib_height * 0.8),
        (cx + canopy_w * 0.65, rib_y + rib_height),
        (cx + canopy_w * 0.65 - 16, rib_y + rib_height + 16),
        (cx, rib_y + 12),
        (cx - canopy_w * 0.65 + 16, rib_y + rib_height + 16),
    ]
    sym_draw.polygon(p_chevron, fill=(225, 175, 45, 255))

    # Digital Sparkles / Barcode lines at bottom
    bar_y = bottom_y + S * 0.04
    bar_w = S * 0.44
    bar_h = S * 0.018

    # Rounded base pedestal
    sym_draw.rounded_rectangle(
        [cx - bar_w / 2, bar_y, cx + bar_w / 2, bar_y + bar_h],
        radius=int(bar_h / 2),
        fill=(16, 185, 129, 230)
    )

    # 3 Gold tick marks representing retail barcode / cashier scan
    tick_w = S * 0.02
    tick_h = S * 0.018
    sym_draw.rounded_rectangle([cx - S * 0.12 - tick_w / 2, bar_y + bar_h + 12, cx - S * 0.12 + tick_w / 2, bar_y + bar_h + 12 + tick_h], radius=4, fill=(245, 208, 97, 240))
    sym_draw.rounded_rectangle([cx - tick_w / 2, bar_y + bar_h + 12, cx + tick_w / 2, bar_y + bar_h + 12 + tick_h], radius=4, fill=(245, 208, 97, 240))
    sym_draw.rounded_rectangle([cx + S * 0.12 - tick_w / 2, bar_y + bar_h + 12, cx + S * 0.12 + tick_w / 2, bar_y + bar_h + 12 + tick_h], radius=4, fill=(245, 208, 97, 240))

    # Composite symbol onto rounded background
    final_img = Image.alpha_composite(rounded_bg, symbol_img)

    # Downsample using high-quality Lanczos filter
    final_resized = final_img.resize((size, size), Image.Resampling.LANCZOS)
    return final_resized

def create_brand_badge(app_icon):
    # Create full marketing showcase badge (1200x1200)
    W, H = 1200, 1200
    badge = Image.new('RGBA', (W, H), (248, 250, 252, 255))
    draw = ImageDraw.Draw(badge)

    # Subtle ambient gradient circle behind icon
    for r in range(480, 0, -10):
        alpha = int(22 * (1 - r / 480))
        draw.ellipse([600 - r, 400 - r, 600 + r, 400 + r], fill=(15, 56, 38, alpha))

    # Paste 420x420 app icon centered at top
    icon_resized = app_icon.resize((420, 420), Image.Resampling.LANCZOS)
    # Icon shadow
    shadow = Image.new('RGBA', (460, 460), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle([20, 20, 440, 440], radius=100, fill=(15, 23, 42, 45))
    shadow = shadow.filter(ImageFilter.GaussianBlur(16))
    badge.paste(shadow, (600 - 230, 400 - 230 + 16), mask=shadow)
    badge.paste(icon_resized, (600 - 210, 400 - 210), mask=icon_resized)

    # Typography
    font_title = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf', 72)
    font_sub = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf', 24)
    font_tag = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 20)

    # Brand Title: WARUNGKU
    title_text = "WARUNGKU"
    bbox_title = draw.textbbox((0, 0), title_text, font=font_title)
    tw = bbox_title[2] - bbox_title[0]
    draw.text((600 - tw / 2, 690), title_text, font=font_title, fill=(15, 23, 42))

    # Gold Accent underline pill
    draw.rounded_rectangle([600 - 45, 785, 600 + 45, 792], radius=4, fill=(201, 151, 0))

    # Subtitle: SISTEM KASIR & KELOLA TOKO
    sub_text = "SISTEM KASIR & KELOLA TOKO MODERN"
    bbox_sub = draw.textbbox((0, 0), sub_text, font=font_sub)
    sw = bbox_sub[2] - bbox_sub[0]
    draw.text((600 - sw / 2, 820), sub_text, font=font_sub, fill=(15, 56, 38))

    # Feature Pills at bottom
    pills = ["⚡ POS Cepat", "📦 Kelola Stok", "📷 Scan Barcode", "📊 Laporan Laba"]
    pill_y = 900
    pill_w = 200
    pill_gap = 16
    total_pills_w = len(pills) * pill_w + (len(pills) - 1) * pill_gap
    start_x = 600 - total_pills_w / 2

    for i, p in enumerate(pills):
        px = start_x + i * (pill_w + pill_gap)
        draw.rounded_rectangle([px, pill_y, px + pill_w, pill_y + 44], radius=22, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        bbox_p = draw.textbbox((0, 0), p, font=font_tag)
        pw = bbox_p[2] - bbox_p[0]
        ph = bbox_p[3] - bbox_p[1]
        draw.text((px + (pill_w - pw) / 2, pill_y + (44 - ph) / 2 - 2), p, font=font_tag, fill=(71, 85, 105))

    return badge

if __name__ == '__main__':
    base_dir = r"C:\Users\hp\dev\toko-kelontong\frontend"
    out_dir = os.path.join(base_dir, "assets", "branding")
    os.makedirs(out_dir, exist_ok=True)

    # 1. Generate Master 1024x1024 Icon
    icon_1024 = create_app_icon(1024)
    master_path = os.path.join(out_dir, "app_icon_1024.png")
    icon_1024.save(master_path, "PNG")

    # 2. Generate Brand Showcase Badge (1200x1200)
    badge = create_brand_badge(icon_1024)
    badge_path = os.path.join(out_dir, "warungku_brand_logo.png")
    badge.save(badge_path, "PNG")

    # 3. Export Android Mipmap Icons
    res_dir = os.path.join(base_dir, "android", "app", "src", "main", "res")
    mipmaps = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, dim in mipmaps.items():
        folder_path = os.path.join(res_dir, folder)
        if os.path.exists(folder_path):
            resized = icon_1024.resize((dim, dim), Image.Resampling.LANCZOS)
            target_path = os.path.join(folder_path, "ic_launcher.png")
            resized.save(target_path, "PNG")
            print(f"Updated {target_path} ({dim}x{dim})")

    print(f"Brand Logo generated at: {badge_path}")
    print(f"Master App Icon generated at: {master_path}")
