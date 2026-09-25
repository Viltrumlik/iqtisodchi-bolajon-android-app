# -*- coding: utf-8 -*-
"""Draws the app launcher icon and the two child avatars.

Everything is rendered at 4x and downsampled, which is what gives the shapes
clean anti-aliased edges without needing a vector toolchain.
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
S = 4  # supersample factor


def canvas(size):
    img = Image.new('RGBA', (size * S, size * S), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def finish(img, size):
    return img.resize((size, size), Image.LANCZOS)


def vgrad(size, top, bottom):
    """Vertical linear gradient as a full-bleed RGBA image."""
    g = Image.new('RGBA', (1, size), (0, 0, 0, 255))
    px = g.load()
    for y in range(size):
        t = y / max(1, size - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)) + (255,)
    return g.resize((size, size), Image.BICUBIC)


def rounded_mask(size, radius):
    m = Image.new('L', (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


# ── Shared face-drawing helpers ───────────────────────────────────────────────

SKIN   = (255, 219, 172)
SKIN_S = (240, 195, 145)
HAIR_B = (62, 39, 35)
HAIR_G = (93, 52, 40)
BLUSH  = (255, 152, 152)
EYE    = (60, 44, 40)
MOUTH  = (196, 78, 78)


def draw_face(d, cx, cy, r, blush=True):
    """Head + eyes + smile, centred on (cx, cy) with radius r."""
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=SKIN, outline=SKIN_S, width=int(r * 0.045))
    # Ears
    er = r * 0.22
    for sx in (-1, 1):
        d.ellipse([cx + sx * r - er, cy - er * 0.6, cx + sx * r + er, cy + er * 1.4],
                  fill=SKIN, outline=SKIN_S, width=int(r * 0.04))
    # Eyes
    ex, ey, erx = r * 0.38, r * 0.12, r * 0.13
    for sx in (-1, 1):
        d.ellipse([cx + sx * ex - erx, cy - ey - erx * 1.25,
                   cx + sx * ex + erx, cy - ey + erx * 1.25], fill=EYE)
        # catch-light
        d.ellipse([cx + sx * ex - erx * 0.15, cy - ey - erx * 0.85,
                   cx + sx * ex + erx * 0.45, cy - ey - erx * 0.25], fill=(255, 255, 255))
    # Blush
    if blush:
        br = r * 0.17
        for sx in (-1, 1):
            d.ellipse([cx + sx * r * 0.62 - br, cy + r * 0.22 - br * 0.7,
                       cx + sx * r * 0.62 + br, cy + r * 0.22 + br * 0.7], fill=BLUSH)
    # Smile
    d.arc([cx - r * 0.42, cy + r * 0.02, cx + r * 0.42, cy + r * 0.62],
          start=15, end=165, fill=MOUTH, width=int(r * 0.09))


def draw_body(d, cx, cy, r, shirt, collar):
    """Shoulders peeking in from the bottom of the frame."""
    top = cy + r * 0.86
    d.rounded_rectangle([cx - r * 1.32, top, cx + r * 1.32, top + r * 1.5],
                        radius=r * 0.5, fill=shirt)
    # Collar
    d.polygon([(cx - r * 0.42, top), (cx + r * 0.42, top), (cx, top + r * 0.42)], fill=collar)
    d.ellipse([cx - r * 0.13, top + r * 0.5, cx + r * 0.13, top + r * 0.76], fill=collar)


# ── Avatars ───────────────────────────────────────────────────────────────────

def avatar(kind, size=512):
    img, d = canvas(size)
    W = size * S
    cx, cy, r = W / 2, W * 0.46, W * 0.27

    # Soft coloured disc behind the child
    bg = (255, 214, 170) if kind == 'boy' else (255, 205, 226)
    ring = (255, 178, 107) if kind == 'boy' else (247, 155, 195)
    d.ellipse([W * 0.045, W * 0.045, W * 0.955, W * 0.955], fill=bg, outline=ring, width=int(W * 0.022))

    if kind == 'girl':
        # Long hair behind the head
        d.ellipse([cx - r * 1.28, cy - r * 1.22, cx + r * 1.28, cy + r * 1.55], fill=HAIR_G)
        # Braids
        for sx in (-1, 1):
            for i, t in enumerate((0.0, 0.42, 0.84)):
                bx = cx + sx * r * (1.16 + t * 0.16)
                by = cy + r * (0.72 + t * 0.78)
                br = r * (0.24 - i * 0.035)
                d.ellipse([bx - br, by - br, bx + br, by + br], fill=HAIR_G)
    else:
        d.ellipse([cx - r * 1.1, cy - r * 1.18, cx + r * 1.1, cy + r * 0.7], fill=HAIR_B)

    draw_body(d, cx, cy, r,
              shirt=(84, 174, 233) if kind == 'boy' else (240, 122, 165),
              collar=(255, 255, 255))
    draw_face(d, cx, cy, r)

    if kind == 'boy':
        # Fringe sweeping across the forehead
        d.chord([cx - r * 1.06, cy - r * 1.16, cx + r * 1.06, cy + r * 0.22],
                start=182, end=358, fill=HAIR_B)
        d.ellipse([cx + r * 0.10, cy - r * 1.10, cx + r * 1.02, cy - r * 0.30], fill=HAIR_B)
    else:
        # Rounded fringe + bow
        d.chord([cx - r * 1.06, cy - r * 1.2, cx + r * 1.06, cy + r * 0.12],
                start=180, end=360, fill=HAIR_G)
        bx, by, bw = cx + r * 0.82, cy - r * 0.74, r * 0.30
        for sx in (-1, 1):
            d.ellipse([bx + sx * bw * 0.62 - bw * 0.72, by - bw * 0.58,
                       bx + sx * bw * 0.62 + bw * 0.72, by + bw * 0.58], fill=(233, 64, 110))
        d.ellipse([bx - bw * 0.3, by - bw * 0.3, bx + bw * 0.3, by + bw * 0.3], fill=(198, 40, 86))

    out = finish(img, size)
    p = os.path.join(ROOT, 'assets/avatars/%s.png' % kind)
    out.save(p)
    print('wrote', p, out.size)


# ── Launcher icon ─────────────────────────────────────────────────────────────

def icon(size=1024):
    img, d = canvas(size)
    W = size * S

    # Bright sky-to-mint background, clipped to Android's rounded-square shape
    bgimg = vgrad(W, (86, 204, 242), (47, 182, 140))
    bgimg.putalpha(rounded_mask(W, int(W * 0.235)))
    img.alpha_composite(bgimg)
    d = ImageDraw.Draw(img)

    # Sun-ray glow behind the coin
    glow = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for i in range(12):
        a = math.radians(i * 30 + 15)
        gd.line([W / 2 + math.cos(a) * W * 0.20, W / 2 + math.sin(a) * W * 0.20,
                 W / 2 + math.cos(a) * W * 0.46, W / 2 + math.sin(a) * W * 0.46],
                fill=(255, 255, 255, 46), width=int(W * 0.035))
    glow = glow.filter(ImageFilter.GaussianBlur(W * 0.006))
    img.alpha_composite(glow)
    d = ImageDraw.Draw(img)

    # Gold coin
    cx, cy, r = W / 2, W * 0.52, W * 0.315
    d.ellipse([cx - r * 1.02, cy - r * 0.98, cx + r * 1.02, cy + r * 1.06], fill=(0, 0, 0, 38))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 193, 46), outline=(226, 150, 12), width=int(W * 0.016))
    d.ellipse([cx - r * 0.855, cy - r * 0.855, cx + r * 0.855, cy + r * 0.855],
              outline=(255, 224, 130), width=int(W * 0.014))

    # Child's face on the coin
    fr = r * 0.60
    fy = cy + r * 0.06
    d.ellipse([cx - fr * 1.06, fy - fr * 1.12, cx + fr * 1.06, fy + fr * 0.28], fill=HAIR_B)
    d.ellipse([cx - fr, fy - fr, cx + fr, fy + fr], fill=SKIN)
    d.chord([cx - fr * 1.03, fy - fr * 1.1, cx + fr * 1.03, fy + fr * 0.18],
            start=182, end=358, fill=HAIR_B)
    d.ellipse([cx + fr * 0.08, fy - fr * 1.05, cx + fr * 1.0, fy - fr * 0.28], fill=HAIR_B)
    ex, ey, erx = fr * 0.36, fr * 0.06, fr * 0.135
    for sx in (-1, 1):
        d.ellipse([cx + sx * ex - erx, fy - ey - erx * 1.3,
                   cx + sx * ex + erx, fy - ey + erx * 1.3], fill=EYE)
        d.ellipse([cx + sx * ex - erx * 0.1, fy - ey - erx * 0.9,
                   cx + sx * ex + erx * 0.5, fy - ey - erx * 0.3], fill=(255, 255, 255))
    br = fr * 0.18
    for sx in (-1, 1):
        d.ellipse([cx + sx * fr * 0.60 - br, fy + fr * 0.26 - br * 0.66,
                   cx + sx * fr * 0.60 + br, fy + fr * 0.26 + br * 0.66], fill=BLUSH)
    d.arc([cx - fr * 0.40, fy + fr * 0.06, cx + fr * 0.40, fy + fr * 0.64],
          start=15, end=165, fill=MOUTH, width=int(fr * 0.12))

    # Graduation cap, tilted
    cap = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cap)
    bw, by = r * 1.02, cy - r * 0.60
    cd.polygon([(cx, by - r * 0.42), (cx + bw, by), (cx, by + r * 0.42), (cx - bw, by)],
               fill=(45, 55, 120))
    cd.rounded_rectangle([cx - r * 0.30, by + r * 0.05, cx + r * 0.30, by + r * 0.40],
                         radius=r * 0.10, fill=(58, 70, 150))
    # Tassel hangs off the board's right tip, out over the background where
    # gold still reads (against the coin it disappears).
    cd.line([cx + bw * 0.97, by + r * 0.02, cx + bw * 1.12, by + r * 0.34,
             cx + bw * 1.08, by + r * 0.80],
            fill=(255, 236, 170), width=int(W * 0.016), joint='curve')
    cd.ellipse([cx + bw * 1.08 - r * 0.125, by + r * 0.78,
                cx + bw * 1.08 + r * 0.125, by + r * 1.05], fill=(255, 236, 170))
    cd.ellipse([cx + bw * 1.08 - r * 0.085, by + r * 0.86,
                cx + bw * 1.08 + r * 0.085, by + r * 1.02], fill=(252, 205, 92))
    cap = cap.rotate(-7, resample=Image.BICUBIC, center=(cx, by))
    img.alpha_composite(cap)
    d = ImageDraw.Draw(img)

    # Sparkles
    for px, py, pr in ((0.16, 0.20, 0.030), (0.855, 0.235, 0.022), (0.115, 0.80, 0.020),
                       (0.88, 0.775, 0.030)):
        x, y, rr = W * px, W * py, W * pr
        d.polygon([(x, y - rr), (x + rr * 0.30, y - rr * 0.30), (x + rr, y),
                   (x + rr * 0.30, y + rr * 0.30), (x, y + rr),
                   (x - rr * 0.30, y + rr * 0.30), (x - rr, y),
                   (x - rr * 0.30, y - rr * 0.30)], fill=(255, 255, 255, 225))

    out = finish(img, size)
    p = os.path.join(ROOT, 'assets/icon/app_icon.png')
    os.makedirs(os.path.dirname(p), exist_ok=True)
    out.save(p)
    print('wrote', p, out.size)
    return out


if __name__ == '__main__':
    avatar('boy')
    avatar('girl')
    base = icon()

    # Android launcher mipmaps
    for folder, px in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
        dst = os.path.join(ROOT, 'android/app/src/main/res/mipmap-%s' % folder)
        os.makedirs(dst, exist_ok=True)
        im = base.resize((px, px), Image.LANCZOS)
        im.save(os.path.join(dst, 'ic_launcher.png'))
        # Round variant: same art masked to a circle
        m = Image.new('L', (px, px), 0)
        ImageDraw.Draw(m).ellipse([0, 0, px - 1, px - 1], fill=255)
        rnd = im.copy(); rnd.putalpha(m)
        rnd.save(os.path.join(dst, 'ic_launcher_round.png'))
        print('  mipmap-%-8s %dpx' % (folder, px))
