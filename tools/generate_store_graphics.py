import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "graphics")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Color Palette Constants
ROSE_LIGHT = (235, 145, 156)
ROSE_MAIN = (217, 114, 127)
ROSE_DARK = (168, 64, 78)
SAGE_LIGHT = (158, 192, 175)
SAGE_MAIN = (126, 159, 142)
SAGE_DARK = (88, 122, 105)
MINT_LOCK = (82, 183, 136)
GOLD_COIN = (233, 168, 37)
GOLD_LIGHT = (255, 215, 105)
CHARCOAL = (43, 45, 66)
CHARCOAL_LIGHT = (90, 93, 115)
CREAM_BG = (250, 250, 249)
WHITE = (255, 255, 255)

FONT_BOLD_PATH = "C:/Windows/Fonts/segoeuib.ttf"
FONT_REG_PATH = "C:/Windows/Fonts/segoeui.ttf"
FONT_EMOJI_PATH = "C:/Windows/Fonts/seguiemj.ttf"

def get_font(size, bold=False):
    path = FONT_BOLD_PATH if bold else FONT_REG_PATH
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.load_default()

def draw_gradient_rect(draw, bbox, color_top, color_bottom):
    x0, y0, x1, y1 = bbox
    height = y1 - y0
    for y in range(int(y0), int(y1)):
        t = (y - y0) / max(1, height)
        r = int(color_top[0] + t * (color_bottom[0] - color_top[0]))
        g = int(color_top[1] + t * (color_bottom[1] - color_top[1]))
        b = int(color_top[2] + t * (color_bottom[2] - color_top[2]))
        draw.line([(x0, y), (x1, y)], fill=(r, g, b))

# -------------------------------------------------------------
# 1. APP ICON (512x512 PNG, RGB)
# -------------------------------------------------------------
def generate_app_icon():
    size = 512
    img = Image.new("RGB", (size, size), ROSE_DARK)
    draw = ImageDraw.Draw(img)

    # Gradient background
    draw_gradient_rect(draw, (0, 0, size, size), ROSE_MAIN, ROSE_DARK)

    # Subtle decorative geometric circle pattern
    for r in range(240, 60, -40):
        draw.ellipse([size/2 - r, size/2 - r, size/2 + r, size/2 + r],
                     outline=(255, 255, 255, 25), width=2)

    # Central crossword tiles: 2x2 grid (K, D / C, W)
    tile_size = 110
    gap = 14
    start_x = (size - (tile_size * 2 + gap)) / 2
    start_y = 110

    letters = [
        ("K", (0, 0), ROSE_MAIN),
        ("D", (1, 0), SAGE_MAIN),
        ("C", (0, 1), SAGE_MAIN),
        ("W", (1, 1), MINT_LOCK)
    ]

    font_tile = get_font(68, bold=True)
    font_num = get_font(20, bold=True)

    for i, (char, (col, row), accent_color) in enumerate(letters, 1):
        tx = start_x + col * (tile_size + gap)
        ty = start_y + row * (tile_size + gap)

        # Shadow
        draw.rounded_rectangle([tx + 4, ty + 6, tx + tile_size + 4, ty + tile_size + 6],
                               radius=18, fill=(0, 0, 0, 60))

        # Tile Body
        draw.rounded_rectangle([tx, ty, tx + tile_size, ty + tile_size],
                               radius=18, fill=WHITE, outline=accent_color, width=4)

        # Small corner clue index
        draw.text((tx + 12, ty + 8), str(i), fill=accent_color, font=font_num)

        # Main Character
        bbox = draw.textbbox((0, 0), char, font=font_tile)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        draw.text((tx + (tile_size - w)/2, ty + (tile_size - h)/2 - 4), char, fill=CHARCOAL, font=font_tile)

    # Bottom Pill Banner: "CROSSWORDS"
    pill_w = 340
    pill_h = 58
    pill_x = (size - pill_w) / 2
    pill_y = 385

    # Shadow
    draw.rounded_rectangle([pill_x + 2, pill_y + 4, pill_x + pill_w + 2, pill_y + pill_h + 4],
                           radius=29, fill=(0, 0, 0, 70))
    # Fill
    draw.rounded_rectangle([pill_x, pill_y, pill_x + pill_w, pill_y + pill_h],
                           radius=29, fill=CREAM_BG, outline=GOLD_COIN, width=3)

    font_pill = get_font(28, bold=True)
    pill_text = "K-DRAMA"
    bbox = draw.textbbox((0, 0), pill_text, font=font_pill)
    pw = bbox[2] - bbox[0]
    draw.text(((size - pw)/2, pill_y + 11), pill_text, fill=CHARCOAL, font=font_pill)

    # Gold Accent Coins in top corners
    for cx, cy in [(68, 68), (size - 68, 68)]:
        draw.ellipse([cx - 24, cy - 24, cx + 24, cy + 24], fill=GOLD_COIN, outline=GOLD_LIGHT, width=3)
        draw.text((cx - 8, cy - 14), "★", fill=WHITE, font=get_font(20, bold=True))

    out_path = os.path.join(OUTPUT_DIR, "app_icon_512.png")
    img.save(out_path, "PNG")
    print(f"Generated App Icon: {out_path} ({os.path.getsize(out_path)} bytes)")
    return out_path

# -------------------------------------------------------------
# 2. FEATURE GRAPHIC (1024x500 PNG)
# -------------------------------------------------------------
def generate_feature_graphic():
    w, h = 1024, 500
    img = Image.new("RGB", (w, h), ROSE_DARK)
    draw = ImageDraw.Draw(img)

    # Horizontal Gradient: Rose into Sage
    for x in range(w):
        t = x / w
        r = int(ROSE_MAIN[0] * (1 - t) + SAGE_MAIN[0] * t)
        g = int(ROSE_MAIN[1] * (1 - t) + SAGE_MAIN[1] * t)
        b = int(ROSE_MAIN[2] * (1 - t) + SAGE_MAIN[2] * t)
        draw.line([(x, 0), (x, h)], fill=(r, g, b))

    # Decorative background curves & circles
    for i in range(5):
        draw.ellipse([w - 300 + i*40, -100 + i*20, w + 200 + i*40, 400 + i*20],
                     outline=(255, 255, 255, 20), width=2)
        draw.ellipse([-150 + i*30, 200 + i*20, 250 + i*30, 600 + i*20],
                     outline=(255, 255, 255, 15), width=2)

    # Left Column: Titles & Taglines
    font_badge = get_font(18, bold=True)
    draw.rounded_rectangle([70, 65, 340, 105], radius=20, fill=WHITE)
    draw.text((95, 74), "100% OFFLINE • ZERO ADS", fill=ROSE_MAIN, font=font_badge)

    font_title_main = get_font(56, bold=True)
    draw.text((70, 125), "K-DRAMA", fill=WHITE, font=font_title_main)
    draw.text((70, 185), "CROSSWORDS", fill=GOLD_LIGHT, font=font_title_main)

    font_sub = get_font(24, bold=False)
    draw.text((72, 265), "400+ Puzzles • 163 Verified Dramas (2010–2026)", fill=CREAM_BG, font=font_sub)

    # Feature Pill Badges
    badges = ["Connected Grids", "Emoji Rebus", "Trophy Lore Cards"]
    bx = 72
    by = 320
    for b in badges:
        bw = draw.textlength(b, font=get_font(18, bold=True)) + 32
        draw.rounded_rectangle([bx, by, bx + bw, by + 40], radius=20, fill=(0, 0, 0, 45), outline=WHITE, width=2)
        draw.text((bx + 16, by + 8), b, fill=WHITE, font=get_font(18, bold=True))
        bx += int(bw) + 16

    # Bottom Legal Shield Note
    font_note = get_font(15, bold=False)
    draw.text((72, 430), "Zero Permissions • Instant 60 FPS • Fair-Use Trivia Lore", fill=(240, 240, 240), font=font_note)

    # Right Column: Visual Puzzle Mockup Cards
    # Card 1: Crossword Mini Grid
    card_x = 650
    card_y = 60
    card_w = 300
    card_h = 360

    # Shadow
    draw.rounded_rectangle([card_x + 8, card_y + 12, card_x + card_w + 8, card_y + card_h + 12],
                           radius=24, fill=(0, 0, 0, 50))
    # White Card Body
    draw.rounded_rectangle([card_x, card_y, card_x + card_w, card_y + card_h],
                           radius=24, fill=WHITE)

    # Card Header
    draw.rounded_rectangle([card_x + 16, card_y + 16, card_x + card_w - 16, card_y + 54],
                           radius=12, fill=CREAM_BG)
    draw.text((card_x + 28, card_y + 23), "Level 1 • Crash Landing on You", fill=CHARCOAL, font=get_font(15, bold=True))

    # Mini 4x4 crossword cells
    grid_start_x = card_x + 36
    grid_start_y = card_y + 70
    cell_s = 50
    grid_cells = [
        ["S", "E", "R", "I"],
        ["E", None, "E", None],
        ["O", None, "E", None],
        ["L", "A", "W", "Y"]
    ]

    for r_idx, row in enumerate(grid_cells):
        for c_idx, val in enumerate(row):
            cx = grid_start_x + c_idx * (cell_s + 6)
            cy = grid_start_y + r_idx * (cell_s + 6)
            if val is not None:
                # Mint lock highlight on solved word
                bg = (220, 245, 230) if r_idx == 0 else CREAM_BG
                border = MINT_LOCK if r_idx == 0 else (210, 210, 215)
                draw.rounded_rectangle([cx, cy, cx + cell_s, cy + cell_s],
                                       radius=8, fill=bg, outline=border, width=2)
                draw.text((cx + 16, cy + 10), val, fill=CHARCOAL, font=get_font(24, bold=True))
            else:
                draw.rounded_rectangle([cx, cy, cx + cell_s, cy + cell_s],
                                       radius=8, fill=(235, 235, 238))

    # Bottom Clue Ribbon
    draw.rounded_rectangle([card_x + 16, card_y + 300, card_x + card_w - 16, card_y + 342],
                           radius=10, fill=(225, 242, 235), outline=MINT_LOCK, width=1)
    draw.text((card_x + 26, card_y + 310), "✓ Solved: 1 Across [SERI]", fill=MINT_LOCK, font=get_font(15, bold=True))

    out_path = os.path.join(OUTPUT_DIR, "feature_graphic_1024x500.png")
    img.save(out_path, "PNG")
    print(f"Generated Feature Graphic: {out_path} ({os.path.getsize(out_path)} bytes)")
    return out_path

# -------------------------------------------------------------
# 3. PHONE SCREENSHOT GENERATOR (1080 x 1920 PNG, 9:16)
# -------------------------------------------------------------
def create_phone_frame(title_banner, subtitle_banner, bg_gradient_top, bg_gradient_bottom):
    w, h = 1080, 1920
    img = Image.new("RGB", (w, h), bg_gradient_top)
    draw = ImageDraw.Draw(img)

    # Background gradient
    draw_gradient_rect(draw, (0, 0, w, h), bg_gradient_top, bg_gradient_bottom)

    # Top Marketing Banner
    font_top = get_font(52, bold=True)
    font_sub = get_font(30, bold=False)

    bbox1 = draw.textbbox((0, 0), title_banner, font=font_top)
    tw1 = bbox1[2] - bbox1[0]
    draw.text(((w - tw1)/2, 90), title_banner, fill=WHITE, font=font_top)

    bbox2 = draw.textbbox((0, 0), subtitle_banner, font=font_sub)
    tw2 = bbox2[2] - bbox2[0]
    draw.text(((w - tw2)/2, 160), subtitle_banner, fill=CREAM_BG, font=font_sub)

    # Phone Mockup Canvas
    phone_w = 880
    phone_h = 1580
    px = (w - phone_w) / 2
    py = 240

    # Phone Shadow
    draw.rounded_rectangle([px + 10, py + 16, px + phone_w + 10, py + phone_h + 16],
                           radius=48, fill=(0, 0, 0, 70))
    # Phone Body Bezel
    draw.rounded_rectangle([px, py, px + phone_w, py + phone_h],
                           radius=48, fill=CHARCOAL, outline=(200, 200, 205), width=4)
    # Phone Screen Glass
    screen_margin = 14
    sx0 = px + screen_margin
    sy0 = py + screen_margin
    sx1 = px + phone_w - screen_margin
    sy1 = py + phone_h - screen_margin
    draw.rounded_rectangle([sx0, sy0, sx1, sy1], radius=38, fill=CREAM_BG)

    # Status Bar inside mockup
    draw.text((sx0 + 36, sy0 + 20), "09:41", fill=CHARCOAL, font=get_font(22, bold=True))
    draw.text((sx1 - 120, sy0 + 20), "100% 🔋", fill=CHARCOAL, font=get_font(18, bold=True))

    return img, draw, (sx0, sy0, sx1, sy1)

# Screenshot 1: Home Dashboard
def generate_screenshot_1():
    img, draw, (sx0, sy0, sx1, sy1) = create_phone_frame(
        "400+ HAND-CRAFTED LEVELS",
        "163 Iconic South Korean Dramas (2010–2026)",
        ROSE_MAIN, ROSE_DARK
    )

    # Header Bar
    draw.text((sx0 + 36, sy0 + 70), "K-DRAMA CROSSWORDS", fill=ROSE_MAIN, font=get_font(32, bold=True))
    draw.rounded_rectangle([sx1 - 160, sy0 + 64, sx1 - 36, sy0 + 112], radius=24, fill=WHITE, outline=GOLD_COIN, width=2)
    draw.text((sx1 - 145, sy0 + 74), "🪙 450", fill=CHARCOAL, font=get_font(24, bold=True))

    # Overall Progress Card
    card_y = sy0 + 140
    card_w = (sx1 - sx0) - 72
    draw.rounded_rectangle([sx0 + 36, card_y, sx1 - 36, card_y + 220], radius=24, fill=WHITE, outline=(225, 225, 230), width=2)
    draw.text((sx0 + 60, card_y + 24), "Game Completion Progress", fill=CHARCOAL, font=get_font(24, bold=True))
    draw.text((sx1 - 130, card_y + 24), "35%", fill=ROSE_MAIN, font=get_font(28, bold=True))

    # Progress bar track
    draw.rounded_rectangle([sx0 + 60, card_y + 70, sx1 - 60, card_y + 90], radius=10, fill=(235, 235, 240))
    bar_fill = (sx0 + 60) + int(((sx1 - sx0) - 120) * 0.35)
    draw.rounded_rectangle([sx0 + 60, card_y + 70, bar_fill, card_y + 90], radius=10, fill=MINT_LOCK)

    draw.text((sx0 + 60, card_y + 115), "Cleared: 140 / 400 Levels", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))
    draw.text((sx0 + 60, card_y + 155), "⭐ 385 Stars Earned • 🏆 68 Trophies", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))

    # Daily Challenge Banner
    dy = card_y + 250
    draw.rounded_rectangle([sx0 + 36, dy, sx1 - 36, dy + 140], radius=24, fill=(255, 248, 230), outline=GOLD_COIN, width=2)
    draw.text((sx0 + 60, dy + 24), "🔥 Daily Challenge • Day 7 Streak", fill=CHARCOAL, font=get_font(26, bold=True))
    draw.text((sx0 + 60, dy + 68), "Play today's featured mystery drama puzzle for +200 bonus coins!", fill=CHARCOAL_LIGHT, font=get_font(18, bold=False))

    # Mode Cards: Classic Crosswords
    my = dy + 170
    draw.rounded_rectangle([sx0 + 36, my, sx1 - 36, my + 180], radius=24, fill=WHITE, outline=ROSE_MAIN, width=3)
    draw.text((sx0 + 60, my + 24), "Classic Crosswords", fill=ROSE_MAIN, font=get_font(32, bold=True))
    draw.text((sx0 + 60, my + 72), "200 Connected grids from Easy to Expert", fill=CHARCOAL, font=get_font(22, bold=False))
    draw.text((sx0 + 60, my + 115), "Level 42: Crash Landing on You • ⭐⭐⭐", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))

    # Mode Cards: Emoji Rebus
    ry = my + 210
    draw.rounded_rectangle([sx0 + 36, ry, sx1 - 36, ry + 180], radius=24, fill=WHITE, outline=SAGE_MAIN, width=3)
    draw.text((sx0 + 60, ry + 24), "Emoji & Icon Rebus", fill=SAGE_MAIN, font=get_font(32, bold=True))
    draw.text((sx0 + 60, ry + 72), "200 Visual riddle titles in Dedicated Word Rows", fill=CHARCOAL, font=get_font(22, bold=False))
    draw.text((sx0 + 60, ry + 115), "Level 38: Squid Game • ⭐⭐⭐", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))

    # Trophy Hall Shortcut
    ty = ry + 210
    draw.rounded_rectangle([sx0 + 36, ty, sx1 - 36, ty + 120], radius=24, fill=WHITE, outline=(220, 220, 225), width=2)
    draw.text((sx0 + 60, ty + 24), "🏆 Trophy Hall (Drama Lore Dex)", fill=CHARCOAL, font=get_font(26, bold=True))
    draw.text((sx0 + 60, ty + 68), "68 / 163 Collectible trivia cards unlocked", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))

    out = os.path.join(OUTPUT_DIR, "screenshot_1_home.png")
    img.save(out, "PNG")
    print(f"Generated Screenshot 1: {out}")

# Screenshot 2: Classic Crosswords
def generate_screenshot_2():
    img, draw, (sx0, sy0, sx1, sy1) = create_phone_frame(
        "CONNECTED CLASSIC CROSSWORDS",
        "Calming Celadon Mint Word-Locking Feedback",
        SAGE_MAIN, SAGE_DARK
    )

    # Top App Bar
    draw.text((sx0 + 36, sy0 + 70), "← Level 12: Goblin", fill=CHARCOAL, font=get_font(30, bold=True))
    draw.rounded_rectangle([sx1 - 160, sy0 + 64, sx1 - 36, sy0 + 112], radius=24, fill=WHITE, outline=GOLD_COIN, width=2)
    draw.text((sx1 - 145, sy0 + 74), "🪙 450", fill=CHARCOAL, font=get_font(24, bold=True))

    # Active Clue Ribbon
    ribbon_y = sy0 + 130
    draw.rounded_rectangle([sx0 + 36, ribbon_y, sx1 - 36, ribbon_y + 90], radius=20, fill=(230, 245, 238), outline=MINT_LOCK, width=2)
    draw.text((sx0 + 56, ribbon_y + 14), "1 Across • 5 Letters", fill=SAGE_DARK, font=get_font(18, bold=True))
    draw.text((sx0 + 56, ribbon_y + 44), "The ancient sword cursed through Kim Shin's chest", fill=CHARCOAL, font=get_font(22, bold=True))

    # 6x6 Crossword Grid Mockup
    grid_y = ribbon_y + 120
    cell_size = 110
    gap = 8
    grid_start_x = sx0 + 70

    grid = [
        [("S", True), ("W", True), ("O", True), ("R", True), ("D", True), None],
        [("W", False), None, ("B", False), None, ("E", False), None],
        [("O", False), None, ("G", False), None, ("A", False), None],
        [("R", False), ("E", False), ("A", False), ("P", False), ("E", False), ("R", False)],
        [("D", False), None, ("T", False), None, ("T", False), None],
        [None, None, ("H", False), None, ("H", False), None],
    ]

    for r_idx, row in enumerate(grid):
        for c_idx, item in enumerate(row):
            cx = grid_start_x + c_idx * (cell_size + gap)
            cy = grid_y + r_idx * (cell_size + gap)

            if item is not None:
                val, is_locked = item
                if is_locked:
                    # Mint green locked cell
                    draw.rounded_rectangle([cx, cy, cx + cell_size, cy + cell_size], radius=16, fill=(215, 245, 230), outline=MINT_LOCK, width=3)
                    draw.text((cx + 10, cy + 6), "✓", fill=MINT_LOCK, font=get_font(20, bold=True))
                else:
                    is_active = (r_idx == 3)
                    bg = (255, 248, 230) if is_active else WHITE
                    border = GOLD_COIN if is_active else (210, 210, 220)
                    draw.rounded_rectangle([cx, cy, cx + cell_size, cy + cell_size], radius=16, fill=bg, outline=border, width=2)

                draw.text((cx + (cell_size - 36)/2, cy + (cell_size - 44)/2), val, fill=CHARCOAL, font=get_font(44, bold=True))
            else:
                draw.rounded_rectangle([cx, cy, cx + cell_size, cy + cell_size], radius=16, fill=(235, 235, 240))

    # Clue Actions / Hint Bar
    act_y = grid_y + 6 * (cell_size + gap) + 30
    draw.rounded_rectangle([sx0 + 36, act_y, sx1 - 36, act_y + 80], radius=24, fill=WHITE, outline=ROSE_MAIN, width=2)
    draw.text((sx0 + 60, act_y + 24), "💡 Need Help? Open Hint Shop", fill=ROSE_MAIN, font=get_font(26, bold=True))
    draw.text((sx1 - 180, act_y + 24), "50–250 🪙", fill=GOLD_COIN, font=get_font(24, bold=True))

    # Keyboard Preview
    kb_y = act_y + 110
    draw.rounded_rectangle([sx0 + 20, kb_y, sx1 - 20, sy1 - 30], radius=24, fill=(240, 240, 245))
    draw.text((sx0 + 40, kb_y + 18), "Native Gboard / Samsung IME Integration", fill=CHARCOAL_LIGHT, font=get_font(20, bold=True))

    out = os.path.join(OUTPUT_DIR, "screenshot_2_crossword.png")
    img.save(out, "PNG")
    print(f"Generated Screenshot 2: {out}")

# Screenshot 3: Dedicated Word Row Rebus
def generate_screenshot_3():
    img, draw, (sx0, sy0, sx1, sy1) = create_phone_frame(
        "EMOJI & ICON TITLE REBUS",
        "Dedicated Word Rows with Inline Fixed Punctuation",
        ROSE_DARK, CHARCOAL
    )

    # Top Bar
    draw.text((sx0 + 36, sy0 + 70), "← Level 15 • Rebus", fill=CHARCOAL, font=get_font(30, bold=True))
    draw.rounded_rectangle([sx1 - 160, sy0 + 64, sx1 - 36, sy0 + 112], radius=24, fill=WHITE, outline=GOLD_COIN, width=2)
    draw.text((sx1 - 145, sy0 + 74), "🪙 600", fill=CHARCOAL, font=get_font(24, bold=True))

    # Visual Riddle Emoji Banner
    ey = sy0 + 140
    draw.rounded_rectangle([sx0 + 36, ey, sx1 - 36, ey + 220], radius=28, fill=WHITE, outline=ROSE_MAIN, width=3)
    draw.text((sx0 + 60, ey + 20), "VISUAL RIDDLE", fill=ROSE_MAIN, font=get_font(22, bold=True))

    # Emoji Glyphs (Crash Landing on You: 🪂 💥 🪖 💖)
    emojis_text = "🪂  💥  🪖  💖"
    font_emoji = get_font(56, bold=False)
    draw.text((sx0 + 120, ey + 75), emojis_text, fill=CHARCOAL, font=font_emoji)
    draw.text((sx0 + 60, ey + 175), "Clue: An heiress paraglides over the DMZ...", fill=CHARCOAL_LIGHT, font=get_font(22, bold=False))

    # Dedicated Word Rows:
    # Row 1: [C][R][A][S][H]
    # Row 2: [L][A][N][D][I][N][G]
    # Row 3: [O][N]
    # Row 4: [Y][O][U]
    words = [
        ["C", "R", "A", "S", "H"],
        ["L", "A", "N", "D", "I", "N", "G"],
        ["O", "N"],
        ["Y", "O", "U"]
    ]

    wy = ey + 260
    for w_idx, word in enumerate(words):
        draw.text((sx0 + 40, wy + 20), f"Word {w_idx + 1}", fill=CHARCOAL_LIGHT, font=get_font(18, bold=True))
        slot_w = 88
        slot_h = 96
        start_x = sx0 + 130
        for s_idx, ch in enumerate(word):
            sx = start_x + s_idx * (slot_w + 10)
            is_solved = (w_idx < 2)
            bg = (220, 245, 230) if is_solved else WHITE
            border = MINT_LOCK if is_solved else (210, 210, 220)
            draw.rounded_rectangle([sx, wy, sx + slot_w, wy + slot_h], radius=16, fill=bg, outline=border, width=2)
            display_char = ch if is_solved else ("_" if s_idx > 1 else ch)
            draw.text((sx + 24, wy + 20), display_char, fill=CHARCOAL, font=get_font(42, bold=True))
        wy += slot_h + 30

    out = os.path.join(OUTPUT_DIR, "screenshot_3_rebus.png")
    img.save(out, "PNG")
    print(f"Generated Screenshot 3: {out}")

# Screenshot 4: 3-Tier Progressive Hint Shop
def generate_screenshot_4():
    img, draw, (sx0, sy0, sx1, sy1) = create_phone_frame(
        "PROGRESSIVE 3-TIER HINT SHOP",
        "Earn Coins Naturally Through Gameplay",
        GOLD_COIN, CHARCOAL
    )

    # Crossword Background behind modal
    draw.text((sx0 + 36, sy0 + 70), "← Level 5: Vincenzo", fill=CHARCOAL, font=get_font(30, bold=True))

    # Modal Dialog Body
    mx = sx0 + 40
    my = sy0 + 180
    mw = (sx1 - sx0) - 80
    mh = 1050

    draw.rounded_rectangle([mx + 8, my + 14, mx + mw + 8, my + mh + 14], radius=32, fill=(0, 0, 0, 70))
    draw.rounded_rectangle([mx, my, mx + mw, my + mh], radius=32, fill=WHITE, outline=GOLD_COIN, width=3)

    # Modal Header
    draw.text((mx + 40, my + 40), "💡 Hint Shop", fill=CHARCOAL, font=get_font(38, bold=True))
    draw.text((mx + 40, my + 95), "Your Balance: 🪙 450 Coins", fill=GOLD_COIN, font=get_font(24, bold=True))

    # Tier 1 Card
    t1_y = my + 160
    draw.rounded_rectangle([mx + 30, t1_y, mx + mw - 30, t1_y + 190], radius=24, fill=(245, 250, 248), outline=SAGE_MAIN, width=2)
    draw.text((mx + 50, t1_y + 24), "Tier 1: Reveal First Letter", fill=CHARCOAL, font=get_font(26, bold=True))
    draw.text((mx + 50, t1_y + 68), "Uncovers the starting letter of the active word.", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))
    draw.rounded_rectangle([mx + mw - 220, t1_y + 115, mx + mw - 50, t1_y + 165], radius=25, fill=SAGE_MAIN)
    draw.text((mx + mw - 195, t1_y + 124), "50 Coins", fill=WHITE, font=get_font(22, bold=True))

    # Tier 2 Card
    t2_y = t1_y + 220
    draw.rounded_rectangle([mx + 30, t2_y, mx + mw - 30, t2_y + 190], radius=24, fill=(255, 250, 240), outline=GOLD_COIN, width=2)
    draw.text((mx + 50, t2_y + 24), "Tier 2: Reveal Another Letter", fill=CHARCOAL, font=get_font(26, bold=True))
    draw.text((mx + 50, t2_y + 68), "Fills in the next unsolved cell in sequence.", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))
    draw.rounded_rectangle([mx + mw - 220, t2_y + 115, mx + mw - 50, t2_y + 165], radius=25, fill=GOLD_COIN)
    draw.text((mx + mw - 205, t2_y + 124), "100 Coins", fill=WHITE, font=get_font(22, bold=True))

    # Tier 3 Card
    t3_y = t2_y + 220
    draw.rounded_rectangle([mx + 30, t3_y, mx + mw - 30, t3_y + 190], radius=24, fill=(255, 240, 243), outline=ROSE_MAIN, width=2)
    draw.text((mx + 50, t3_y + 24), "Tier 3: Solve Entire Word", fill=CHARCOAL, font=get_font(26, bold=True))
    draw.text((mx + 50, t3_y + 68), "Instantly solves and locks the entire selected word.", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))
    draw.rounded_rectangle([mx + mw - 220, t3_y + 115, mx + mw - 50, t3_y + 165], radius=25, fill=ROSE_MAIN)
    draw.text((mx + mw - 205, t3_y + 124), "250 Coins", fill=WHITE, font=get_font(22, bold=True))

    # Earning note
    draw.text((mx + 50, t3_y + 230), "+50 per word • +100 per rebus • +200 level bonus", fill=CHARCOAL_LIGHT, font=get_font(20, bold=True))

    out = os.path.join(OUTPUT_DIR, "screenshot_4_hint_shop.png")
    img.save(out, "PNG")
    print(f"Generated Screenshot 4: {out}")

# Screenshot 5: Collectible Trophy Dex
def generate_screenshot_5():
    img, draw, (sx0, sy0, sx1, sy1) = create_phone_frame(
        "COLLECTIBLE TROPHY HALL / DEX",
        "Verified Behind-The-Scenes Trivia Lore Cards",
        CHARCOAL, ROSE_DARK
    )

    # Top Bar
    draw.text((sx0 + 36, sy0 + 70), "🏆 Trophy Hall & Lore Dex", fill=CHARCOAL, font=get_font(30, bold=True))
    draw.text((sx0 + 36, sy0 + 110), "68 of 163 Collectible Drama Cards Unlocked", fill=CHARCOAL_LIGHT, font=get_font(20, bold=False))

    # Filter Chips
    cy = sy0 + 160
    chips = [("All (68)", True), ("tvN (24)", False), ("Netflix (18)", False), ("JTBC (12)", False)]
    cx = sx0 + 36
    for label, active in chips:
        bg = ROSE_MAIN if active else WHITE
        fg = WHITE if active else CHARCOAL
        bw = draw.textlength(label, font=get_font(20, bold=True)) + 36
        draw.rounded_rectangle([cx, cy, cx + bw, cy + 50], radius=25, fill=bg, outline=ROSE_MAIN, width=2)
        draw.text((cx + 18, cy + 12), label, fill=fg, font=get_font(20, bold=True))
        cx += int(bw) + 14

    # Lore Card 1: Extraordinary Attorney Woo
    card1_y = cy + 80
    draw.rounded_rectangle([sx0 + 36, card1_y, sx1 - 36, card1_y + 360], radius=28, fill=WHITE, outline=SAGE_MAIN, width=3)
    draw.text((sx0 + 64, card1_y + 30), "Extraordinary Attorney Woo (2022)", fill=CHARCOAL, font=get_font(28, bold=True))
    draw.text((sx0 + 64, card1_y + 70), "Studio: ENA / Netflix • Legal / Drama", fill=SAGE_DARK, font=get_font(18, bold=True))

    fact_text_1 = (
        "Park Eun-bin initially turned down the role of Woo Young-woo\n"
        "because she felt a deep responsibility portraying autism accurately,\n"
        "leading director Yoo In-shik to wait an entire year for her."
    )
    draw.text((sx0 + 64, card1_y + 110), fact_text_1, fill=CHARCOAL, font=get_font(20, bold=False))
    draw.rounded_rectangle([sx0 + 64, card1_y + 240, sx1 - 64, card1_y + 320], radius=16, fill=CREAM_BG)
    draw.text((sx0 + 80, card1_y + 252), "Dual Verification Sources (Fair-Use Accredited):", fill=CHARCOAL_LIGHT, font=get_font(16, bold=True))
    draw.text((sx0 + 80, card1_y + 280), "1. Nielsen Korea Ratings Record  |  2. Official ENA Production Press", fill=CHARCOAL_LIGHT, font=get_font(16, bold=False))

    # Lore Card 2: Queen of Tears
    card2_y = card1_y + 390
    draw.rounded_rectangle([sx0 + 36, card2_y, sx1 - 36, card2_y + 360], radius=28, fill=WHITE, outline=ROSE_MAIN, width=3)
    draw.text((sx0 + 64, card2_y + 30), "Queen of Tears (2024)", fill=CHARCOAL, font=get_font(28, bold=True))
    draw.text((sx0 + 64, card2_y + 70), "Network: tvN / Studio Dragon • Romance / Melodrama", fill=ROSE_DARK, font=get_font(18, bold=True))

    fact_text_2 = (
        "Surpassed 'Crash Landing on You' to become the highest-rated\n"
        "drama in tvN history, reaching a staggering 24.85% national rating\n"
        "for its emotional final broadcast."
    )
    draw.text((sx0 + 64, card2_y + 110), fact_text_2, fill=CHARCOAL, font=get_font(20, bold=False))
    draw.rounded_rectangle([sx0 + 64, card2_y + 240, sx1 - 64, card2_y + 320], radius=16, fill=CREAM_BG)
    draw.text((sx0 + 80, card2_y + 252), "Dual Verification Sources (Fair-Use Accredited):", fill=CHARCOAL_LIGHT, font=get_font(16, bold=True))
    draw.text((sx0 + 80, card2_y + 280), "1. Nielsen Korea Broadcast Index  |  2. Yonhap News Agency", fill=CHARCOAL_LIGHT, font=get_font(16, bold=False))

    out = os.path.join(OUTPUT_DIR, "screenshot_5_trophy_dex.png")
    img.save(out, "PNG")
    print(f"Generated Screenshot 5: {out}")

def main():
    print("Generating Store Graphic Assets...")
    generate_app_icon()
    generate_feature_graphic()
    generate_screenshot_1()
    generate_screenshot_2()
    generate_screenshot_3()
    generate_screenshot_4()
    generate_screenshot_5()
    print("All store graphics successfully generated in docs/graphics/!")

if __name__ == "__main__":
    main()
