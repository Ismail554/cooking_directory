import math
import os
from PIL import Image, ImageDraw

# Colors
C_TERRACOTTA = (230, 81, 0, 255)
C_TERRACOTTA_DARK = (172, 25, 0, 255)
C_TERRACOTTA_LIGHT = (255, 131, 58, 255)
C_PEACH = (255, 224, 178, 255)
C_WHITE = (255, 255, 255, 255)
C_HERB = (46, 125, 50, 255)
C_HERB_LIGHT = (96, 173, 94, 255)
C_MINT = (200, 230, 201, 255)
C_SAFFRON = (255, 160, 0, 255)
C_SAFFRON_LIGHT = (255, 213, 79, 255)
C_LINEN = (251, 249, 246, 255)
C_OATMEAL = (243, 239, 234, 255)
C_BORDER = (229, 224, 216, 255)
C_CHARCOAL = (26, 26, 26, 255)
C_GREY = (108, 108, 108, 255)
C_CORAL = (255, 112, 67, 255)
C_GROCERY_GREEN = (76, 175, 80, 255)

def draw_chef_hat(draw, cx, cy, scale, fill_hat=C_WHITE, stroke_hat=C_TERRACOTTA, fill_band=C_PEACH, stroke_band=C_TERRACOTTA, band_accent=C_HERB):
    """Draws a stylized culinary chef hat centered around cx, cy."""
    # Band at base
    bw = int(140 * scale)
    bh = int(38 * scale)
    by = int(cy + 40 * scale)
    bx0 = cx - bw // 2
    bx1 = cx + bw // 2
    by0 = by
    by1 = by + bh
    
    # Billows (5 puffs of toque)
    puffs = [
        (-60, 10, 36),
        (-35, -25, 42),
        (0, -45, 48),
        (35, -25, 42),
        (60, 10, 36),
    ]
    
    # Fill billow body polygon/ellipses
    for dx, dy, r in puffs:
        px = cx + int(dx * scale)
        py = cy + int(dy * scale)
        pr = int(r * scale)
        draw.ellipse([px - pr, py - pr, px + pr, py + pr], fill=fill_hat, outline=stroke_hat, width=max(1, int(4 * scale)))
    
    # Fill center to cover seams
    center_box = [cx - int(55 * scale), cy - int(20 * scale), cx + int(55 * scale), by0 + int(10 * scale)]
    draw.rectangle(center_box, fill=fill_hat)
    
    # Draw band
    draw.rounded_rectangle([bx0, by0, bx1, by1], radius=int(8 * scale), fill=fill_band, outline=stroke_band, width=max(1, int(4 * scale)))
    
    # Green accent stripe in band
    sh = int(10 * scale)
    sy0 = by0 + (bh - sh) // 2
    sy1 = sy0 + sh
    margin = int(10 * scale)
    draw.rounded_rectangle([bx0 + margin, sy0, bx1 - margin, sy1], radius=int(4 * scale), fill=band_accent)


def create_app_logo(out_path):
    w, h = 512, 512
    scale = 4
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = sw // 2, sh // 2
    r_outer = int(220 * scale)
    
    # Outer soft drop shadow
    for i in range(12):
        alpha = int(18 - i * 1.5)
        r = r_outer + (12 - i) * scale
        draw.ellipse([cx - r, cy - r + int(6 * scale), cx + r, cy + r + int(6 * scale)], fill=(200, 180, 160, alpha))
    
    # Golden Saffron accent ring
    draw.ellipse([cx - r_outer, cy - r_outer, cx + r_outer, cy + r_outer], fill=C_SAFFRON)
    
    # Terracotta primary badge
    r_mid = int(202 * scale)
    draw.ellipse([cx - r_mid, cy - r_mid, cx + r_mid, cy + r_mid], fill=C_TERRACOTTA)
    
    # Inner subtle rim
    r_inner = int(186 * scale)
    draw.ellipse([cx - r_inner, cy - r_inner, cx + r_inner, cy + r_inner], outline=C_TERRACOTTA_LIGHT, width=int(5 * scale))
    
    # Laurel / Herb green leaves framing lower semicircle
    num_leaves = 7
    for side in (-1, 1):
        for i in range(num_leaves):
            ang = 35 + i * 14
            rad = math.radians(ang)
            dist = r_inner - int(24 * scale)
            lx = cx + side * int(dist * math.cos(rad))
            ly = cy + int(dist * math.sin(rad))
            lr = int(16 * scale)
            # Leaf ellipse
            leaf_box = [lx - lr, ly - int(lr * 0.6), lx + lr, ly + int(lr * 0.6)]
            draw.ellipse(leaf_box, fill=C_HERB_LIGHT if i % 2 == 0 else C_HERB)
    
    # Center chef hat
    draw_chef_hat(draw, cx, cy - int(12 * scale), scale * 1.35, fill_hat=C_WHITE, stroke_hat=C_TERRACOTTA_DARK, fill_band=C_PEACH, stroke_band=C_TERRACOTTA_DARK, band_accent=C_HERB)
    
    # Crossed wooden spoons / utensils below hat
    ut_w = int(120 * scale)
    ut_y = cy + int(95 * scale)
    draw.ellipse([cx - int(28 * scale), ut_y - int(10 * scale), cx + int(28 * scale), ut_y + int(10 * scale)], fill=C_SAFFRON)
    
    # Small star accents
    for sx, sy in [(-80, -70), (80, -70), (0, -130)]:
        px = cx + int(sx * scale)
        py = cy + int(sy * scale)
        sr = int(8 * scale)
        draw.ellipse([px - sr, py - sr, px + sr, py + sr], fill=C_SAFFRON_LIGHT)
    
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_splash_bg(out_path):
    w, h = 1125, 2436
    img = Image.new("RGBA", (w, h), C_LINEN)
    draw = ImageDraw.Draw(img)
    
    # Vertical gradient from Linen (251, 249, 246) to Peach (255, 224, 178)
    for y in range(h):
        t = y / (h - 1)
        r = int(251 + (255 - 251) * t)
        g = int(249 + (224 - 249) * t)
        b = int(246 + (178 - 246) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
    
    # Overlay subtle culinary watermark line art
    # Grid of scattered motifs: pots, whisks, leaves, steam
    wm_terracotta = (230, 81, 0, 16)  # ~6% opacity
    wm_saffron = (255, 160, 0, 14)
    wm_herb = (46, 125, 50, 12)
    
    cols = 6
    rows = 12
    dx = w / cols
    dy = h / rows
    
    for row in range(rows):
        for col in range(cols):
            cx = int(col * dx + dx * 0.5 + ((row % 2) * (dx * 0.25)))
            cy = int(row * dy + dy * 0.5)
            motif_type = (row + col) % 4
            
            if motif_type == 0:
                # Mini pot
                draw.rounded_rectangle([cx - 24, cy - 8, cx + 24, cy + 20], radius=8, outline=wm_terracotta, width=3)
                draw.line([cx - 28, cy - 4, cx - 24, cy - 4], fill=wm_terracotta, width=3)
                draw.line([cx + 24, cy - 4, cx + 28, cy - 4], fill=wm_terracotta, width=3)
                draw.arc([cx - 16, cy - 18, cx + 16, cy - 6], 0, 180, fill=wm_saffron, width=2)
            elif motif_type == 1:
                # Herb sprig
                draw.line([cx - 15, cy + 18, cx + 15, cy - 18], fill=wm_herb, width=2)
                draw.ellipse([cx - 10, cy - 4, cx - 2, cy + 4], outline=wm_herb, width=2)
                draw.ellipse([cx + 2, cy - 12, cx + 10, cy - 4], outline=wm_herb, width=2)
            elif motif_type == 2:
                # Whisk / spoon
                draw.line([cx, cy - 20, cx, cy + 20], fill=wm_terracotta, width=3)
                draw.ellipse([cx - 12, cy - 24, cx + 12, cy - 4], outline=wm_saffron, width=2)
            else:
                # Steam swirl / sparkle
                draw.arc([cx - 12, cy - 16, cx + 12, cy + 16], 45, 270, fill=wm_saffron, width=2)
                draw.arc([cx - 6, cy - 8, cx + 6, cy + 8], 225, 90, fill=wm_terracotta, width=2)
    
    # Vignette corner shading
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_recipe_placeholder(out_path):
    w, h = 600, 400
    scale = 2
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), C_OATMEAL)
    draw = ImageDraw.Draw(img)
    
    # Inner white card with rounded border
    margin = 24 * scale
    draw.rounded_rectangle([margin, margin, sw - margin, sh - margin], radius=20 * scale, fill=C_WHITE, outline=C_BORDER, width=2 * scale)
    
    cx, cy = sw // 2, sh // 2
    
    # Food Cloche Dome
    # Base platter
    pw = 180 * scale
    ph = 14 * scale
    py = cy + 40 * scale
    draw.rounded_rectangle([cx - pw, py, cx + pw, py + ph], radius=7 * scale, fill=C_TERRACOTTA)
    
    # Dome
    dw = 150 * scale
    dh = 110 * scale
    draw.pieslice([cx - dw, py - dh * 2 + ph, cx + dw, py + ph], 180, 360, fill=C_PEACH, outline=C_TERRACOTTA, width=4 * scale)
    
    # Dome handle (knob)
    kw = 18 * scale
    draw.ellipse([cx - kw, py - dh + ph - 24 * scale, cx + kw, py - dh + ph], fill=C_SAFFRON, outline=C_TERRACOTTA_DARK, width=3 * scale)
    
    # Fork and spoon silhouette in center of cloche
    draw.line([cx - 30 * scale, py - 40 * scale, cx - 30 * scale, py - 10 * scale], fill=C_TERRACOTTA, width=3 * scale)
    draw.line([cx + 30 * scale, py - 40 * scale, cx + 30 * scale, py - 10 * scale], fill=C_TERRACOTTA, width=3 * scale)
    draw.ellipse([cx - 36 * scale, py - 60 * scale, cx - 24 * scale, py - 38 * scale], fill=C_TERRACOTTA)
    draw.ellipse([cx + 24 * scale, py - 60 * scale, cx + 36 * scale, py - 38 * scale], fill=C_TERRACOTTA)
    
    # Steam curls above dome knob
    for offset, shift in [(-25 * scale, -10), (0, 0), (25 * scale, 10)]:
        sx = cx + offset
        sy = py - dh - 35 * scale + shift
        draw.arc([sx - 10 * scale, sy - 15 * scale, sx + 10 * scale, sy + 15 * scale], 60, 240, fill=C_TERRACOTTA_LIGHT, width=3 * scale)
        
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_default_avatar(out_path):
    w, h = 256, 256
    scale = 4
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = sw // 2, sh // 2
    r = int(118 * scale)
    
    # Background circle
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=C_PEACH, outline=C_TERRACOTTA, width=int(6 * scale))
    
    # Chef silhouette body (shoulders)
    body_top = cy + int(45 * scale)
    draw.pieslice([cx - int(95 * scale), body_top - int(20 * scale), cx + int(95 * scale), cy + int(120 * scale)], 0, 180, fill=C_TERRACOTTA)
    
    # Green scarf / collar
    draw.polygon([
        (cx - int(28 * scale), body_top),
        (cx + int(28 * scale), body_top),
        (cx, body_top + int(36 * scale))
    ], fill=C_HERB)
    
    # Head
    hr = int(32 * scale)
    hcy = cy - int(2 * scale)
    draw.ellipse([cx - hr, hcy - hr, cx + hr, hcy + hr], fill=C_TERRACOTTA)
    
    # Chef toque on head
    draw_chef_hat(draw, cx, hcy - int(38 * scale), scale * 0.72, fill_hat=C_WHITE, stroke_hat=C_TERRACOTTA_DARK, fill_band=C_WHITE, stroke_band=C_TERRACOTTA_DARK, band_accent=C_HERB)
    
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_empty_state(out_path):
    w, h = 500, 500
    scale = 3
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = sw // 2, sh // 2
    
    # Soft ground shadow
    draw.ellipse([cx - int(160 * scale), cy + int(80 * scale), cx + int(160 * scale), cy + int(120 * scale)], fill=(229, 224, 216, 160))
    
    # Clean ceramic skillet / pan
    pan_w = int(140 * scale)
    pan_h = int(60 * scale)
    pan_y = cy + int(40 * scale)
    
    # Pan handle
    draw.rounded_rectangle([cx + pan_w - int(10 * scale), pan_y - int(10 * scale), cx + pan_w + int(80 * scale), pan_y + int(10 * scale)], radius=int(6 * scale), fill=C_TERRACOTTA_DARK)
    draw.ellipse([cx + pan_w + int(60 * scale), pan_y - int(5 * scale), cx + pan_w + int(72 * scale), pan_y + int(5 * scale)], fill=C_WHITE)
    
    # Pan body
    draw.chord([cx - pan_w, pan_y - pan_h, cx + pan_w, pan_y + pan_h], 0, 180, fill=C_TERRACOTTA, outline=C_TERRACOTTA_DARK, width=int(5 * scale))
    draw.ellipse([cx - pan_w, pan_y - pan_h // 2, cx + pan_w, pan_y + pan_h // 2], fill=C_PEACH, outline=C_TERRACOTTA, width=int(4 * scale))
    
    # Whispering steam swirls
    for sx, sy, flip in [(-50, -30, 1), (0, -60, -1), (50, -25, 1)]:
        px = cx + int(sx * scale)
        py = cy + int(sy * scale)
        sr = int(22 * scale)
        start_a = 45 if flip == 1 else 135
        end_a = 225 if flip == 1 else 315
        draw.arc([px - sr, py - sr, px + sr, py + sr], start_a, end_a, fill=C_TERRACOTTA_LIGHT, width=int(4 * scale))
        draw.arc([px - sr // 2, py - sr - sr // 2, px + sr // 2, py - sr // 2], 0, 180, fill=C_SAFFRON, width=int(3 * scale))
    
    # Floating cute ingredients (sparkles, herb leaf, peppercorn)
    # Herb leaf
    draw.ellipse([cx - int(100 * scale), cy - int(40 * scale), cx - int(70 * scale), cy - int(20 * scale)], fill=C_HERB)
    draw.line([cx - int(100 * scale), cy - int(30 * scale), cx - int(65 * scale), cy - int(30 * scale)], fill=C_HERB_LIGHT, width=int(2 * scale))
    
    # Golden star sparkles
    for sx, sy, size in [(90, -80, 12), (-80, -90, 9), (110, 10, 8), (-110, 15, 8)]:
        px = cx + int(sx * scale)
        py = cy + int(sy * scale)
        s = int(size * scale)
        draw.ellipse([px - s, py - s, px + s, py + s], fill=C_SAFFRON)
    
    # Pepper grains
    for px, py in [(-40, 20), (20, 30), (-10, 45), (40, 25)]:
        x = cx + int(px * scale)
        y = cy + int(py * scale)
        r = int(3 * scale)
        draw.ellipse([x - r, y - r, x + r, y + r], fill=C_CHARCOAL)
        
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_ic_timer(out_path):
    w, h = 128, 128
    scale = 4
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = sw // 2, sh // 2 + int(6 * scale)
    r = int(48 * scale)
    
    # Top plunger / button
    draw.rounded_rectangle([cx - int(10 * scale), cy - r - int(16 * scale), cx + int(10 * scale), cy - r], radius=int(3 * scale), fill=C_TERRACOTTA_DARK)
    draw.rounded_rectangle([cx - int(16 * scale), cy - r - int(22 * scale), cx + int(16 * scale), cy - r - int(14 * scale)], radius=int(4 * scale), fill=C_TERRACOTTA)
    
    # Outer timer body
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=C_TERRACOTTA, outline=C_TERRACOTTA_DARK, width=int(4 * scale))
    
    # Inner dial face
    ri = int(38 * scale)
    draw.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=C_LINEN, outline=C_BORDER, width=int(2 * scale))
    
    # Dial tick marks
    for i in range(12):
        ang = i * 30
        rad = math.radians(ang)
        is_cardinal = (i % 3 == 0)
        len_tick = int(7 * scale) if is_cardinal else int(4 * scale)
        tx0 = cx + int((ri - int(2 * scale)) * math.cos(rad))
        ty0 = cy + int((ri - int(2 * scale)) * math.sin(rad))
        tx1 = cx + int((ri - int(2 * scale) - len_tick) * math.cos(rad))
        ty1 = cy + int((ri - int(2 * scale) - len_tick) * math.sin(rad))
        draw.line([(tx0, ty0), (tx1, ty1)], fill=C_TERRACOTTA_DARK if is_cardinal else C_GREY, width=int(3 * scale) if is_cardinal else int(1.5 * scale))
        
    # Timer hands (pointing to ~20 min / 120 degrees)
    hand_rad = math.radians(120 - 90)
    hx = cx + int(24 * scale * math.cos(hand_rad))
    hy = cy + int(24 * scale * math.sin(hand_rad))
    draw.line([(cx, cy), (hx, hy)], fill=C_TERRACOTTA_DARK, width=int(4 * scale))
    
    # Saffron center pin
    cr = int(5 * scale)
    draw.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=C_SAFFRON)
    
    # Herb green checkmark accent on top-right
    chk_x = cx + int(38 * scale)
    chk_y = cy - int(34 * scale)
    chk_r = int(14 * scale)
    draw.ellipse([chk_x - chk_r, chk_y - chk_r, chk_x + chk_r, chk_y + chk_r], fill=C_HERB)
    draw.line([chk_x - int(6 * scale), chk_y, chk_x - int(2 * scale), chk_y + int(5 * scale)], fill=C_WHITE, width=int(3 * scale))
    draw.line([chk_x - int(2 * scale), chk_y + int(5 * scale), chk_x + int(6 * scale), chk_y - int(4 * scale)], fill=C_WHITE, width=int(3 * scale))
    
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_ic_recipe(out_path):
    w, h = 128, 128
    scale = 4
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = sw // 2, sh // 2
    
    # Cookbook cover
    bw = int(84 * scale)
    bh = int(100 * scale)
    bx0 = cx - bw // 2
    by0 = cy - bh // 2
    bx1 = bx0 + bw
    by1 = by0 + bh
    
    # Book pages shadow / edge
    draw.rounded_rectangle([bx0 + int(6 * scale), by0 + int(4 * scale), bx1 + int(6 * scale), by1 + int(4 * scale)], radius=int(8 * scale), fill=C_OATMEAL)
    
    # Book cover
    draw.rounded_rectangle([bx0, by0, bx1, by1], radius=int(8 * scale), fill=C_TERRACOTTA)
    
    # Spine strip on left
    draw.rounded_rectangle([bx0, by0, bx0 + int(18 * scale), by1], radius=int(6 * scale), fill=C_TERRACOTTA_DARK)
    
    # Ribbon bookmark hanging from top
    rx0 = cx + int(8 * scale)
    rw = int(14 * scale)
    rh = int(45 * scale)
    draw.polygon([
        (rx0, by0),
        (rx0 + rw, by0),
        (rx0 + rw, by0 + rh),
        (rx0 + rw // 2, by0 + rh - int(6 * scale)),
        (rx0, by0 + rh)
    ], fill=C_SAFFRON)
    
    # Embossed chef hat symbol on front cover
    draw_chef_hat(draw, cx + int(12 * scale), cy + int(10 * scale), scale * 0.35, fill_hat=C_PEACH, stroke_hat=C_PEACH, fill_band=C_PEACH, stroke_band=C_PEACH, band_accent=C_SAFFRON)
    
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


def create_ic_expense(out_path):
    w, h = 128, 128
    scale = 4
    sw, sh = w * scale, h * scale
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = sw // 2, sh // 2 + int(6 * scale)
    
    # Grocery Basket / Bag
    bw = int(80 * scale)
    bh = int(60 * scale)
    by0 = cy - int(10 * scale)
    bx0 = cx - bw // 2
    bx1 = cx + bw // 2
    by1 = by0 + bh
    
    # Produce peeking out of basket (Carrot & Green Leek/Herb)
    # Carrot
    draw.polygon([
        (cx - int(24 * scale), by0 - int(28 * scale)),
        (cx - int(12 * scale), by0 - int(32 * scale)),
        (cx - int(8 * scale), by0 + int(5 * scale)),
        (cx - int(20 * scale), by0 + int(5 * scale))
    ], fill=C_CORAL)
    # Carrot greens
    draw.line([cx - int(18 * scale), by0 - int(28 * scale), cx - int(26 * scale), by0 - int(40 * scale)], fill=C_HERB, width=int(3 * scale))
    draw.line([cx - int(18 * scale), by0 - int(28 * scale), cx - int(16 * scale), by0 - int(44 * scale)], fill=C_HERB_LIGHT, width=int(3 * scale))
    
    # Celery / Herb stalk
    draw.line([cx - int(2 * scale), by0 + int(5 * scale), cx + int(6 * scale), by0 - int(36 * scale)], fill=C_HERB, width=int(5 * scale))
    draw.ellipse([cx + int(4 * scale), by0 - int(42 * scale), cx + int(14 * scale), by0 - int(32 * scale)], fill=C_HERB_LIGHT)
    
    # Basket handle
    hw = int(32 * scale)
    hh = int(36 * scale)
    draw.arc([cx - hw, by0 - hh, cx + hw, by0 + int(8 * scale)], 180, 360, fill=C_TERRACOTTA_DARK, width=int(5 * scale))
    
    # Basket body (trapezoid)
    draw.polygon([
        (bx0, by0),
        (bx1, by0),
        (bx1 - int(8 * scale), by1),
        (bx0 + int(8 * scale), by1)
    ], fill=C_GROCERY_GREEN, outline=C_HERB, width=int(3 * scale))
    
    # Weave lines on basket
    for offset_y in [18, 36]:
        y_w = by0 + int(offset_y * scale)
        draw.line([bx0 + int(5 * scale), y_w, bx1 - int(5 * scale), y_w], fill=C_MINT, width=int(2 * scale))
    
    # Coin / Currency badge in foreground
    coin_x = cx + int(24 * scale)
    coin_y = cy + int(18 * scale)
    coin_r = int(20 * scale)
    draw.ellipse([coin_x - coin_r, coin_y - coin_r, coin_x + coin_r, coin_y + coin_r], fill=C_SAFFRON, outline=C_TERRACOTTA, width=int(3 * scale))
    
    # Dollar sign on coin
    draw.line([coin_x, coin_y - int(12 * scale), coin_x, coin_y + int(12 * scale)], fill=C_WHITE, width=int(3 * scale))
    draw.arc([coin_x - int(7 * scale), coin_y - int(10 * scale), coin_x + int(7 * scale), coin_y], 90, 270, fill=C_WHITE, width=int(3 * scale))
    draw.arc([coin_x - int(7 * scale), coin_y, coin_x + int(7 * scale), coin_y + int(10 * scale)], 270, 90, fill=C_WHITE, width=int(3 * scale))
    
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(out_path, "PNG")
    print(f"Created {out_path} ({w}x{h})")


if __name__ == "__main__":
    os.makedirs("assets/images", exist_ok=True)
    os.makedirs("assets/icons", exist_ok=True)
    
    create_app_logo("assets/images/app_logo.png")
    create_splash_bg("assets/images/splash_bg.png")
    create_recipe_placeholder("assets/images/recipe_placeholder.png")
    create_default_avatar("assets/images/default_avatar.png")
    create_empty_state("assets/images/empty_state.png")
    
    create_ic_timer("assets/icons/ic_timer.png")
    create_ic_recipe("assets/icons/ic_recipe.png")
    create_ic_expense("assets/icons/ic_expense.png")
    print("All PNG assets generated successfully!")
