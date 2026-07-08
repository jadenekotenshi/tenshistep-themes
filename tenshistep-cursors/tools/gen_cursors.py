#!/usr/bin/env python3
"""
Generate the TenshiSTEP IRIX Xcursor theme and its preview contact sheet.

Idiom: SGI IRIX / 4Dwm (Motif) pointers -- bold solid-black shapes with a
crisp white outline for contrast on any background, an engineering crosshair,
and a Motif wristwatch as the "busy" indicator.

Shapes are drawn hard-edged into two L masks at high resolution (M px on a
nominal N-grid), then LANCZOS-downscaled to each target size for clean
anti-aliasing. Straight-alpha ARGB is packed into real Xcursor binary files by
a small pure-Python encoder (no xcursorgen/inkscape needed). Alias symlinks map
the canonical shapes onto the full freedesktop + legacy X cursor-name set.

Usage:
    ./gen_cursors.py            # build theme + preview
    ./gen_cursors.py --theme    # theme only
    ./gen_cursors.py --preview  # preview only

Outputs (relative to the repo):
    tenshistep-cursors/TenshiSTEP-IRIX/{index.theme,cursor.theme,cursors/*}
    tenshistep-cursors/previews/cursors.png
"""
import os
import struct
import subprocess
import sys
from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), '..')
THEME = os.path.join(ROOT, 'TenshiSTEP-IRIX')
PREVIEW = os.path.join(ROOT, 'previews', 'cursors.png')

N = 24          # nominal cursor grid
M = 256         # master render resolution
U = M / N       # nominal -> master scale
T = 1.3         # outline thickness in nominal units
SIZES = [24, 32, 48, 64]

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)

HELVETICA = ('/System/Library/Fonts/Helvetica.ttc',
             '/System/Library/Fonts/HelveticaNeue.ttc',
             '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
             '/Library/Fonts/Arial.ttf')


def _font(px, bold=False):
    for path in HELVETICA:
        try:
            return ImageFont.truetype(path, px, index=(1 if bold else 0))
        except Exception:
            try:
                return ImageFont.truetype(path, px)
            except Exception:
                pass
    return ImageFont.load_default()


def rot(pts, deg, cx=12.0, cy=12.0):
    import math
    a = math.radians(deg)
    ca, sa = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * ca - (y - cy) * sa,
             cy + (x - cx) * sa + (y - cy) * ca) for x, y in pts]


# ---------------------------------------------------------------------------
# One cursor: accumulate ink (black) and paper (white outline) masks.
# ---------------------------------------------------------------------------
class Cur:
    def __init__(self, hotspot):
        self.hx, self.hy = hotspot
        self.bm = Image.new('L', (M, M), 0)   # black ink
        self.wm = Image.new('L', (M, M), 0)   # white paper/outline
        self.db = ImageDraw.Draw(self.bm)
        self.dw = ImageDraw.Draw(self.wm)

    def _P(self, pts):
        return [(x * U, y * U) for x, y in pts]

    def poly(self, pts):
        """Filled black polygon with a white outline of thickness ~T."""
        P = self._P(pts)
        w = int(round(2 * T * U))
        self.dw.polygon(P, fill=255)
        self.dw.line(P + [P[0]], fill=255, width=w, joint='curve')
        self.db.polygon(P, fill=255)

    def rrect(self, x0, y0, x1, y1, r):
        """Filled black rounded rect with white outline (union-friendly)."""
        self.dw.rounded_rectangle([(x0 - T) * U, (y0 - T) * U,
                                   (x1 + T) * U, (y1 + T) * U],
                                  radius=(r + T) * U, fill=255)
        self.db.rounded_rectangle([x0 * U, y0 * U, x1 * U, y1 * U],
                                  radius=r * U, fill=255)

    def disk(self, cx, cy, r, mask):
        d = self.db if mask == 'b' else self.dw
        d.ellipse([(cx - r) * U, (cy - r) * U, (cx + r) * U, (cy + r) * U],
                  fill=255)

    def clear(self, cx, cy, r, mask):
        d = self.db if mask == 'b' else self.dw
        d.ellipse([(cx - r) * U, (cy - r) * U, (cx + r) * U, (cy + r) * U],
                  fill=0)

    def bar(self, x0, y0, x1, y1, w):
        """Black segment (round caps) with white outline; nominal coords."""
        self.dw.line([x0 * U, y0 * U, x1 * U, y1 * U], fill=255,
                     width=int(round((w + 2 * T) * U)), joint='curve')
        self.db.line([x0 * U, y0 * U, x1 * U, y1 * U], fill=255,
                     width=int(round(w * U)), joint='curve')

    def _thin(self, x0, y0, x1, y1, w):
        """Thin black segment only (sits on the watch's white face)."""
        self.db.line([x0 * U, y0 * U, x1 * U, y1 * U], fill=255,
                     width=int(round(w * U)), joint='curve')

    def glyph(self, ch, cx, cy, px):
        f = _font(int(round(px * U)), bold=True)
        self.dw.text((cx * U, cy * U), ch, font=f, fill=255, anchor='mm',
                     stroke_width=int(round(T * U)))
        self.db.text((cx * U, cy * U), ch, font=f, fill=255, anchor='mm')

    def watch(self, cx, cy, R, bands=True):
        """Motif wristwatch, reusable at any centre/radius."""
        rim_in = R * 0.72
        if bands:
            bw = R * 0.62
            self.rrect(cx - bw / 2, cy - R - R * 0.75, cx + bw / 2,
                       cy - R + 0.4, r=bw * 0.35)
            self.rrect(cx - bw / 2, cy + R - 0.4, cx + bw / 2,
                       cy + R + R * 0.75, r=bw * 0.35)
        self.disk(cx, cy, R + T, 'w')          # outline + white face
        self.disk(cx, cy, R, 'b')              # black rim...
        self.clear(cx, cy, rim_in, 'b')        # ...hollowed to show face
        hw = R * 0.16
        self._thin(cx, cy, cx, cy - rim_in * 0.82, hw)          # minute -> 12
        self._thin(cx, cy, cx - rim_in * 0.6, cy - rim_in * 0.42, hw)  # hour
        self.db.ellipse([(cx - R * 0.12) * U, (cy - R * 0.12) * U,
                         (cx + R * 0.12) * U, (cy + R * 0.12) * U], fill=255)

    def frames(self):
        out = []
        for s in SIZES:
            bm = self.bm.resize((s, s), Image.LANCZOS)
            wm = self.wm.resize((s, s), Image.LANCZOS)
            alpha = ImageChops.lighter(bm, wm)
            rgb = Image.new('RGB', (s, s), WHITE)
            rgb.paste(BLACK, (0, 0), bm)       # black over white face, AA edge
            img = rgb.convert('RGBA')
            img.putalpha(alpha)
            out.append((s, img, int(round(self.hx * s / N)),
                        int(round(self.hy * s / N))))
        return out


# ---------------------------------------------------------------------------
# Xcursor binary encoder
# ---------------------------------------------------------------------------
IMG_TYPE = 0xFFFD0002


def write_xcursor(path, frames):
    ntoc = len(frames)
    header = struct.pack('<4sIII', b'Xcur', 16, 0x00010000, ntoc)
    toc = b''
    chunks = b''
    pos = 16 + ntoc * 12
    for size, img, xh, yh in frames:
        w, h = img.size
        toc += struct.pack('<III', IMG_TYPE, size, pos + len(chunks))
        px = img.tobytes('raw', 'BGRA')        # little-endian ARGB, straight alpha
        chunks += struct.pack('<IIIIIIIII', 36, IMG_TYPE, size, 1,
                              w, h, xh, yh, 0) + px
    with open(path, 'wb') as f:
        f.write(header + toc + chunks)


# ---------------------------------------------------------------------------
# The cursor set
# ---------------------------------------------------------------------------
ARROW = [(1, 1), (1, 16.5), (5, 12.7), (7.7, 19.5), (10, 18.6),
         (7.4, 11.9), (12.5, 11.9)]
HDA = [(1, 12), (5, 9), (5, 10.8), (19, 10.8), (19, 9), (23, 12),
       (19, 15), (19, 13.2), (5, 13.2), (5, 15)]
FLEUR = [(12, 1), (15, 4), (13.3, 4), (13.3, 10.7), (20, 10.7), (20, 9),
         (23, 12), (20, 15), (20, 13.3), (13.3, 13.3), (13.3, 20), (15, 20),
         (12, 23), (9, 20), (10.7, 20), (10.7, 13.3), (4, 13.3), (4, 15),
         (1, 12), (4, 9), (4, 10.7), (10.7, 10.7), (10.7, 4), (9, 4)]


def build_cursors():
    C = {}

    a = Cur((1, 1)); a.poly(ARROW); C['left_ptr'] = a

    x = Cur((12, 12))
    x.poly([(8, 4), (16, 4), (16, 6), (13, 6), (13, 18), (16, 18), (16, 20),
            (8, 20), (8, 18), (11, 18), (11, 6), (8, 6)])
    C['xterm'] = x

    h = Cur((9, 2))
    h.rrect(6.5, 9, 17.6, 21, 2.2)          # palm
    h.rrect(4.6, 11.3, 8.6, 15.2, 1.8)      # thumb
    h.rrect(7.8, 2.0, 10.3, 14, 1.2)        # index
    h.rrect(10.6, 6.5, 12.7, 14, 1.0)       # finger 2
    h.rrect(12.9, 7.2, 15.0, 14, 1.0)       # finger 3
    h.rrect(15.1, 8.2, 17.1, 14, 1.0)       # finger 4
    C['hand2'] = h

    w = Cur((12, 12)); w.watch(12, 12, 6.6); C['watch'] = w

    c = Cur((12, 12))
    for r in [(1, 11, 10, 13), (14, 11, 23, 13),
              (11, 1, 13, 10), (11, 14, 13, 23)]:
        c.rrect(*r, 0.2)
    C['crosshair'] = c

    hd = Cur((12, 12)); hd.poly(HDA); C['sb_h_double_arrow'] = hd
    vd = Cur((12, 12)); vd.poly(rot(HDA, 90)); C['sb_v_double_arrow'] = vd
    fd = Cur((12, 12)); fd.poly(rot(HDA, 45)); C['size_fdiag'] = fd
    bd = Cur((12, 12)); bd.poly(rot(HDA, -45)); C['size_bdiag'] = bd

    fl = Cur((12, 12)); fl.poly(FLEUR); C['fleur'] = fl

    q = Cur((1, 1)); q.poly(ARROW); q.glyph('?', 17.5, 16.5, 11)
    C['question_arrow'] = q

    p = Cur((1, 1)); p.poly(ARROW); p.watch(17.5, 17, 4.4, bands=False)
    C['left_ptr_watch'] = p

    z = Cur((12, 12))
    z.disk(12, 12, 8 + T, 'w'); z.clear(12, 12, 5 - T, 'w')
    z.disk(12, 12, 8, 'b'); z.clear(12, 12, 5, 'b')
    z.bar(6.8, 6.8, 17.2, 17.2, 2.4)        # slash
    C['circle'] = z

    return C


# canonical name -> alias names (symlinks); covers freedesktop + legacy X names
ALIASES = {
    'left_ptr': ['default', 'arrow', 'top_left_arrow', 'left_arrow',
                 'context-menu'],
    'xterm': ['text', 'ibeam'],
    'hand2': ['hand1', 'hand', 'pointer', 'pointing_hand', 'openhand', 'grab',
              'grabbing', 'closedhand'],
    'watch': ['wait'],
    'left_ptr_watch': ['progress'],
    'crosshair': ['cross', 'tcross', 'plus', 'cross_reverse'],
    'sb_h_double_arrow': ['ew-resize', 'col-resize', 'h_double_arrow',
                          'size_hor', 'e-resize', 'w-resize'],
    'sb_v_double_arrow': ['ns-resize', 'row-resize', 'v_double_arrow',
                          'size_ver', 'n-resize', 's-resize'],
    'size_fdiag': ['nwse-resize', 'nw-resize', 'se-resize',
                   'top_left_corner', 'bottom_right_corner'],
    'size_bdiag': ['nesw-resize', 'ne-resize', 'sw-resize',
                   'top_right_corner', 'bottom_left_corner'],
    'fleur': ['move', 'all-scroll', 'size_all', 'closedhand_move'],
    'question_arrow': ['help', 'whats_this', 'dnd-ask', 'left_ptr_help'],
    'circle': ['not-allowed', 'forbidden', 'no-drop', 'dnd-none',
               'crossed_circle'],
}


def build_theme():
    cdir = os.path.join(THEME, 'cursors')
    os.makedirs(cdir, exist_ok=True)
    C = build_cursors()
    for name, cur in C.items():
        write_xcursor(os.path.join(cdir, name), cur.frames())
    n_alias = 0
    for canon, aliases in ALIASES.items():
        for a in aliases:
            if a == canon:
                continue
            link = os.path.join(cdir, a)
            if os.path.islink(link) or os.path.exists(link):
                os.remove(link)
            os.symlink(canon, link)
            n_alias += 1
    # NB: keep every value on ONE line -- a leading-space "continuation" line is
    # not valid Desktop-Entry/index.theme syntax and can make the cursor KCM fail
    # to parse the theme (so it never appears in System Settings).
    with open(os.path.join(THEME, 'index.theme'), 'w') as f:
        f.write('[Icon Theme]\n'
                'Name=TenshiSTEP IRIX\n'
                'Comment=SGI IRIX-idiom pointers (TenshiNET / TenshiSTEP): bold '
                'black shapes, white outline, engineering crosshair, Motif '
                'wristwatch.\n'
                'Inherits=Adwaita\n')
    # cursor.theme matches the Adwaita convention (Inherits=<own dir name>, no Name).
    with open(os.path.join(THEME, 'cursor.theme'), 'w') as f:
        f.write('[Icon Theme]\nInherits=TenshiSTEP-IRIX\n')
    print('theme: %d pointers, %d aliases -> %s'
          % (len(C), n_alias, os.path.normpath(THEME)))
    return C


# ---------------------------------------------------------------------------
# Motif/4Dwm-style preview contact sheet
# ---------------------------------------------------------------------------
def build_preview(C=None):
    C = C or build_cursors()
    SS = 2

    def px(v):
        return int(round(v * SS))

    def pfont(size, bold=False):
        return _font(px(size), bold=bold)

    GREY, LIGHT, DARK = (176, 176, 168), (214, 214, 206), (108, 108, 102)
    FACE_L, FACE_D = (200, 200, 192), (48, 50, 56)
    TEAL_A, TEAL_B, TITLE, INK = (28, 78, 92), (14, 46, 56), (58, 84, 96), (32, 34, 38)

    ORDER = ['left_ptr', 'xterm', 'hand2', 'crosshair',
             'sb_h_double_arrow', 'sb_v_double_arrow', 'size_fdiag', 'size_bdiag',
             'fleur', 'watch', 'left_ptr_watch', 'circle', 'question_arrow']

    def bevel(d, x0, y0, x1, y1, w, raised=True):
        tl, br = (LIGHT, DARK) if raised else (DARK, LIGHT)
        for i in range(px(w)):
            d.line([(x0 + i, y0 + i), (x1 - i, y0 + i)], fill=tl)
            d.line([(x0 + i, y0 + i), (x0 + i, y1 - i)], fill=tl)
            d.line([(x1 - i, y0 + i), (x1 - i, y1 - i)], fill=br)
            d.line([(x0 + i, y1 - i), (x1 - i, y1 - i)], fill=br)

    COLS, ROWS = 4, 4
    CELL_W, CELL_H, PADX, PADY = 176, 132, 22, 20
    TITLE_H, BORDER, MARGIN = 34, 3, 30
    inner_w = COLS * CELL_W + (COLS + 1) * PADX
    inner_h = ROWS * CELL_H + (ROWS + 1) * PADY
    win_w = inner_w + 2 * BORDER
    win_h = TITLE_H + inner_h + 2 * BORDER
    W, H = win_w + 2 * MARGIN, win_h + 2 * MARGIN + 8

    img = Image.new('RGB', (px(W), px(H)), TEAL_A)
    d = ImageDraw.Draw(img)
    for y in range(px(H)):
        t = y / px(H)
        d.line([(0, y), (px(W), y)],
               fill=tuple(int(TEAL_A[i] + (TEAL_B[i] - TEAL_A[i]) * t)
                          for i in range(3)))

    ox, oy = px(MARGIN), px(MARGIN)
    wx1, wy1 = ox + px(win_w), oy + px(win_h)
    d.rectangle([ox + px(6), oy + px(6), wx1 + px(6), wy1 + px(6)], fill=(8, 26, 32))
    d.rectangle([ox, oy, wx1, wy1], fill=GREY)
    bevel(d, ox, oy, wx1, wy1, BORDER, raised=True)

    tx0, ty0 = ox + px(BORDER), oy + px(BORDER)
    tx1, ty1 = wx1 - px(BORDER), ty0 + px(TITLE_H)
    d.rectangle([tx0, ty0, tx1, ty1], fill=TITLE)
    bevel(d, tx0, ty0, tx1, ty1, 2, raised=True)
    bs = px(TITLE_H) - px(10)
    bx, by = tx0 + px(6), ty0 + px(5)
    d.rectangle([bx, by, bx + bs, by + bs], fill=GREY)
    bevel(d, bx, by, bx + bs, by + bs, 2, True)
    d.rectangle([bx + px(4), by + bs // 2 - px(2), bx + bs - px(4), by + bs // 2 + px(2)], fill=INK)
    for k in range(2):
        qx = tx1 - px(6) - k * (bs + px(6)) - bs
        d.rectangle([qx, by, qx + bs, by + bs], fill=GREY)
        bevel(d, qx, by, qx + bs, by + bs, 2, True)
        if k == 0:
            d.rectangle([qx + px(4), by + px(4), qx + bs - px(4), by + bs - px(4)],
                        outline=INK, width=px(1))
            d.line([qx + px(4), by + px(5), qx + bs - px(4), by + px(5)], fill=INK, width=px(2))
        else:
            m = px(3)
            d.rectangle([qx + bs // 2 - m, by + bs // 2 - m, qx + bs // 2 + m, by + bs // 2 + m],
                        outline=INK, width=px(1))
    d.text(((tx0 + tx1) // 2, (ty0 + ty1) // 2), 'TenshiSTEP  IRIX  —  Pointer Set',
           font=pfont(15, bold=True), fill=(238, 244, 246), anchor='mm')

    lf, sf = pfont(12), pfont(10)
    top = ty1
    for idx, name in enumerate(ORDER):
        r, c = divmod(idx, COLS)
        x = tx0 + px(PADX) + c * px(CELL_W + PADX)
        y = top + px(PADY) + r * px(CELL_H + PADY)
        sw_w, sw_h = px(CELL_W), px(CELL_H - 30)
        d.rectangle([x, y, x + sw_w // 2, y + sw_h], fill=FACE_L)
        d.rectangle([x + sw_w // 2, y, x + sw_w, y + sw_h], fill=FACE_D)
        bevel(d, x, y, x + sw_w, y + sw_h, 2, raised=False)
        im64 = {sz: im for sz, im, xh, yh in C[name].frames()}[64]
        disp = px(52)
        cimg = im64.resize((disp, disp), Image.LANCZOS)
        img.paste(cimg, (x + sw_w // 2 - disp // 2, y + sw_h // 2 - disp // 2), cimg)
        d.text((x + sw_w // 2, y + sw_h + px(15)), name, font=lf, fill=INK, anchor='mm')

    fy = top + px(PADY) + ROWS * px(CELL_H + PADY) - px(6)
    d.text((tx0 + px(PADX), fy),
           'Xcursor · sizes 24/32/48/64 · 13 pointers, 69 names · black ink, white outline',
           font=sf, fill=DARK, anchor='lm')

    os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
    img.resize((W, H), Image.LANCZOS).save(PREVIEW)
    print('preview: %s' % os.path.normpath(PREVIEW))


def sync_bundles():
    """Mirror the freshly-built canonical theme into the per-theme bundles so the
    copies used by each install.sh can never drift from tenshistep-cursors/."""
    script = os.path.join(os.path.dirname(__file__), 'sync-bundles.sh')
    try:
        subprocess.run(['bash', script], check=True)
    except Exception as e:  # never fail the build over the mirror step
        print('warning: could not sync per-theme cursor bundles: %s' % e, file=sys.stderr)


def main(argv):
    do_theme = '--preview' not in argv
    do_preview = '--theme' not in argv
    C = build_theme() if do_theme else None
    if do_theme:
        sync_bundles()
    if do_preview:
        build_preview(C)


if __name__ == '__main__':
    main(sys.argv[1:])
