#!/usr/bin/env python3
"""
Generate the TenshiSTEP-zirconium Aurorae window decoration (decoration.svg):
NeXTSTEP 9-slice frame + title bar, brushed-metal medium steel gray with a
soft sheen gradient and irregular angled grain on the title bar / side frame
/ resize bar / maximized bands -- same texture language as qstyle, Kvantum,
and the Plasma Style (tools/grain.py). Active grid at (10,10); inactive
+200px; maximized below -- geometry matches TenshiSTEP-zirconiumrc.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from grain import brushed_metal_svg, metal_sheen_stops

OUT = os.path.join(os.path.dirname(__file__), '..', 'aurorae', 'TenshiSTEP-zirconium', 'decoration.svg')

FRAME = '#1a1a1a'
HI = '#ffffff'
SH = '#5c5e60'
BASE = '#9a9d9f'
INACTIVE_FRAME = '#4a4a4a'
INACTIVE_HI = '#dcdcdc'
INACTIVE_SH = '#7a7a7a'
INACTIVE_BASE = '#9d9d9d'

_grad_id = [0]
_defs = []

def sheen(base_hex):
    _grad_id[0] += 1
    gid = f'sheen{_grad_id[0]}'
    stops = ''.join(f'<stop offset="{off}" stop-color="{c}"/>' for off, c in metal_sheen_stops(base_hex))
    _defs.append(f'<linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">{stops}</linearGradient>')
    return f'url(#{gid})'

def brushed_band(x, y, w, h, base):
    """A full sheen+grain fill for a band wide enough to carry the texture."""
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{sheen(base)}"/>' + \
           brushed_metal_svg(x, y, w, h, x * 131 + y * 977 + w * 13 + h * 29)

g = []  # (id, content) pairs, each wrapped in <g transform=...>

def emit(gid, tx, ty, content):
    g.append(f'<g id="{gid}" transform="translate({tx},{ty})">{content}</g>')

# ===================== ACTIVE =====================
emit('decoration-topleft', 10, 10,
     f'<rect x="0" y="0" width="1" height="24" fill="{FRAME}"/>'
     f'<rect x="1" y="0" width="1" height="24" fill="{BASE}"/>'
     f'<rect x="1" y="0" width="1" height="1" fill="{FRAME}"/>'
     f'<rect x="1" y="1" width="1" height="1" fill="{HI}"/>'
     f'<rect x="1" y="22" width="1" height="1" fill="{SH}"/>'
     f'<rect x="1" y="23" width="1" height="1" fill="{FRAME}"/>')

emit('decoration-top', 12, 10,
     brushed_band(0, 0, 20, 24, BASE) +
     f'<rect x="0" y="0" width="20" height="1" fill="{FRAME}"/>'
     f'<rect x="0" y="1" width="20" height="1" fill="{HI}"/>'
     f'<rect x="0" y="22" width="20" height="1" fill="{SH}"/>'
     f'<rect x="0" y="23" width="20" height="1" fill="{FRAME}"/>')

emit('decoration-topright', 32, 10,
     f'<rect x="1" y="0" width="1" height="24" fill="{FRAME}"/>'
     f'<rect x="0" y="0" width="1" height="24" fill="{BASE}"/>'
     f'<rect x="0" y="0" width="1" height="1" fill="{FRAME}"/>'
     f'<rect x="0" y="1" width="1" height="1" fill="{HI}"/>'
     f'<rect x="0" y="22" width="1" height="1" fill="{SH}"/>'
     f'<rect x="0" y="23" width="1" height="1" fill="{FRAME}"/>')

emit('decoration-left', 10, 34,
     f'<rect x="0" y="0" width="1" height="20" fill="{FRAME}"/>'
     f'<rect x="1" y="0" width="1" height="20" fill="{SH}"/>')

emit('decoration-center', 12, 34, brushed_band(0, 0, 20, 20, BASE))

emit('decoration-right', 32, 34,
     f'<rect x="1" y="0" width="1" height="20" fill="{FRAME}"/>'
     f'<rect x="0" y="0" width="1" height="20" fill="{SH}"/>')

emit('decoration-bottomleft', 10, 54,
     f'<rect x="0" y="0" width="1" height="8" fill="{FRAME}"/>'
     f'<rect x="1" y="0" width="1" height="8" fill="{BASE}"/>'
     f'<rect x="1" y="0" width="1" height="1" fill="{SH}"/>'
     f'<rect x="1" y="6" width="1" height="1" fill="{SH}"/>'
     f'<rect x="1" y="7" width="1" height="1" fill="{FRAME}"/>')

emit('decoration-bottom', 12, 54,
     brushed_band(0, 0, 20, 8, BASE) +
     f'<rect x="0" y="0" width="20" height="1" fill="{SH}"/>'
     f'<rect x="0" y="6" width="20" height="1" fill="{SH}"/>'
     f'<rect x="0" y="7" width="20" height="1" fill="{FRAME}"/>')

emit('decoration-bottomright', 32, 54,
     f'<rect x="1" y="0" width="1" height="8" fill="{FRAME}"/>'
     f'<rect x="0" y="0" width="1" height="8" fill="{BASE}"/>'
     f'<rect x="0" y="0" width="1" height="1" fill="{SH}"/>'
     f'<rect x="0" y="6" width="1" height="1" fill="{SH}"/>'
     f'<rect x="0" y="7" width="1" height="1" fill="{FRAME}"/>')

# ===================== INACTIVE =====================
emit('decoration-inactive-topleft', 210, 10,
     f'<rect x="0" y="0" width="1" height="24" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="1" y="0" width="1" height="24" fill="{INACTIVE_BASE}"/>'
     f'<rect x="1" y="0" width="1" height="1" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="1" y="1" width="1" height="1" fill="{INACTIVE_HI}"/>'
     f'<rect x="1" y="22" width="1" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="1" y="23" width="1" height="1" fill="{INACTIVE_FRAME}"/>')

emit('decoration-inactive-top', 212, 10,
     brushed_band(0, 0, 20, 24, INACTIVE_BASE) +
     f'<rect x="0" y="0" width="20" height="1" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="0" y="1" width="20" height="1" fill="{INACTIVE_HI}"/>'
     f'<rect x="0" y="22" width="20" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="0" y="23" width="20" height="1" fill="{INACTIVE_FRAME}"/>')

emit('decoration-inactive-topright', 232, 10,
     f'<rect x="1" y="0" width="1" height="24" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="0" y="0" width="1" height="24" fill="{INACTIVE_BASE}"/>'
     f'<rect x="0" y="0" width="1" height="1" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="0" y="1" width="1" height="1" fill="{INACTIVE_HI}"/>'
     f'<rect x="0" y="22" width="1" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="0" y="23" width="1" height="1" fill="{INACTIVE_FRAME}"/>')

emit('decoration-inactive-left', 210, 34,
     f'<rect x="0" y="0" width="1" height="20" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="1" y="0" width="1" height="20" fill="{INACTIVE_SH}"/>')

emit('decoration-inactive-center', 212, 34, brushed_band(0, 0, 20, 20, INACTIVE_BASE))

emit('decoration-inactive-right', 232, 34,
     f'<rect x="1" y="0" width="1" height="20" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="0" y="0" width="1" height="20" fill="{INACTIVE_SH}"/>')

emit('decoration-inactive-bottomleft', 210, 54,
     f'<rect x="0" y="0" width="1" height="8" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="1" y="0" width="1" height="8" fill="{INACTIVE_BASE}"/>'
     f'<rect x="1" y="0" width="1" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="1" y="6" width="1" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="1" y="7" width="1" height="1" fill="{INACTIVE_FRAME}"/>')

emit('decoration-inactive-bottom', 212, 54,
     brushed_band(0, 0, 20, 8, INACTIVE_BASE) +
     f'<rect x="0" y="0" width="20" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="0" y="6" width="20" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="0" y="7" width="20" height="1" fill="{INACTIVE_FRAME}"/>')

emit('decoration-inactive-bottomright', 232, 54,
     f'<rect x="1" y="0" width="1" height="8" fill="{INACTIVE_FRAME}"/>'
     f'<rect x="0" y="0" width="1" height="8" fill="{INACTIVE_BASE}"/>'
     f'<rect x="0" y="0" width="1" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="0" y="6" width="1" height="1" fill="{INACTIVE_SH}"/>'
     f'<rect x="0" y="7" width="1" height="1" fill="{INACTIVE_FRAME}"/>')

# ============ MAXIMIZED (center-only, opaque) ============
emit('decoration-maximized-center', 10, 150,
     brushed_band(0, 0, 40, 24, BASE) +
     f'<rect x="0" y="0" width="40" height="1" fill="{HI}"/>'
     f'<rect x="0" y="23" width="40" height="1" fill="{FRAME}"/>')
emit('decoration-maximized-opaque-center', 60, 150,
     brushed_band(0, 0, 40, 24, BASE) +
     f'<rect x="0" y="0" width="40" height="1" fill="{HI}"/>'
     f'<rect x="0" y="23" width="40" height="1" fill="{FRAME}"/>')
emit('decoration-maximized-inactive-center', 10, 190,
     brushed_band(0, 0, 40, 24, INACTIVE_BASE) +
     f'<rect x="0" y="0" width="40" height="1" fill="{INACTIVE_HI}"/>'
     f'<rect x="0" y="23" width="40" height="1" fill="{INACTIVE_FRAME}"/>')
emit('decoration-maximized-opaque-inactive-center', 60, 190,
     brushed_band(0, 0, 40, 24, INACTIVE_BASE) +
     f'<rect x="0" y="0" width="40" height="1" fill="{INACTIVE_HI}"/>'
     f'<rect x="0" y="23" width="40" height="1" fill="{INACTIVE_FRAME}"/>')

svg = ('<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n'
       '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="400" height="400">\n'
       '  <!-- NeXTSTEP Aurorae decoration, zirconium (brushed-metal) variant: contiguous\n'
       '       column-aligned 3x3 grid, corners == edge width (no gutter). 2px side frame,\n'
       '       uniform raised resize bar, with a soft metal-sheen gradient and irregular\n'
       '       angled brushed-aluminum grain on the title bar / side frame / resize bar /\n'
       '       maximized bands, generated by tools/gen_aurorae.py, same texture language\n'
       '       as qstyle/Kvantum/Plasma Style. Active grid at (10,10); inactive +200px;\n'
       '       maximized below. -->\n'
       f'  <defs>{"".join(_defs)}</defs>\n  '
       + '\n  '.join(g) + '\n</svg>\n')
os.makedirs(os.path.dirname(OUT), exist_ok=True)
open(OUT, 'w').write(svg)
print(f"generated {OUT} ({len(g)} elements, {len(_defs)} gradient defs)")
