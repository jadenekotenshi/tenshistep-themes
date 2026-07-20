#!/usr/bin/env python3
"""
Generate the TenshiSTEP-zirconium Kvantum SVG (TenshiSTEP-zirconium.svg). Kvantum looks up
widgets by SVG element id: interior = "<base>-<status>", frame parts =
"<base>-<status>-<edge>" (top/bottom/left/right + 4 corners). We bake the NeXT
chiselled bevel into the frame parts, a soft metal-sheen gradient into the flat
interior fill, and an irregular, slightly-angled brushed-aluminum grain on top
-- same texture language as the native qstyle plugin (tools/grain.py), aiming
for the old Enlightenment "BrushedMetal" look rather than an engineered stripe.

Authored without Kvantum to test against — verify/tune in Kvantum Manager.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from grain import brushed_metal_svg, metal_sheen_stops

OUT = os.path.join(os.path.dirname(__file__), '..', 'kvantum', 'TenshiSTEP-zirconium')
FRAME = '#1a1a1a'; BLUE = '#487697'
els = []
_y = [0]
_grad_id = [0]
_defs = []

def sheen_fill(base_hex):
    """A metal-sheen linearGradient def for this base colour; returns its url()."""
    _grad_id[0] += 1
    gid = f'sheen{_grad_id[0]}'
    stops = ''.join(f'<stop offset="{off}" stop-color="{c}"/>' for off, c in metal_sheen_stops(base_hex))
    _defs.append(f'<linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">{stops}</linearGradient>')
    return f'url(#{gid})'

def region(ox, oy, w, h, rp, cp, base, frame, raised, grained=True):
    hi, sh = '#ffffff', '#5c5e60'
    itl = hi if raised else '#7a7c7e'
    ibr = sh if raised else '#ffffff'
    fillref = sheen_fill(base) if (len(base) == 7 and base.startswith('#') and grained) else base
    r = [f'<rect x="{ox}" y="{oy}" width="{w}" height="{h}" fill="{fillref}"/>']
    if rp == 'mid' and cp == 'mid' and grained:
        clip_def, body = brushed_metal_svg(ox, oy, w, h, ox * 131 + oy * 977 + w * 13 + h * 29)
        _defs.append(clip_def)
        r.append(body)
    if rp == 'top':    r.append(f'<rect x="{ox}" y="{oy}" width="{w}" height="1" fill="{frame}"/>')
    if rp == 'bottom': r.append(f'<rect x="{ox}" y="{oy+h-1}" width="{w}" height="1" fill="{frame}"/>')
    if cp == 'left':   r.append(f'<rect x="{ox}" y="{oy}" width="1" height="{h}" fill="{frame}"/>')
    if cp == 'right':  r.append(f'<rect x="{ox+w-1}" y="{oy}" width="1" height="{h}" fill="{frame}"/>')
    if rp == 'top':    r.append(f'<rect x="{ox}" y="{oy+1}" width="{w}" height="1" fill="{itl}"/>')
    if cp == 'left':   r.append(f'<rect x="{ox+1}" y="{oy}" width="1" height="{h}" fill="{itl}"/>')
    if rp == 'bottom': r.append(f'<rect x="{ox}" y="{oy+h-2}" width="{w}" height="1" fill="{ibr}"/>')
    if cp == 'right':  r.append(f'<rect x="{ox+w-2}" y="{oy}" width="1" height="{h}" fill="{ibr}"/>')
    return ''.join(r)

def framed(base, status, fill, frame, raised, Wb=40, Hb=22, c=4, grip=False, grained=True):
    oy = _y[0]; ox = 4; _y[0] += Hb + 6
    xs = [(ox, c, 'left'), (ox + c, Wb - 2 * c, 'mid'), (ox + Wb - c, c, 'right')]
    ys = [(oy, c, 'top'), (oy + c, Hb - 2 * c, 'mid'), (oy + Hb - c, c, 'bottom')]
    grid = {('top', 'left'): 'topleft', ('top', 'mid'): 'top', ('top', 'right'): 'topright',
            ('mid', 'left'): 'left', ('mid', 'mid'): None, ('mid', 'right'): 'right',
            ('bottom', 'left'): 'bottomleft', ('bottom', 'mid'): 'bottom', ('bottom', 'right'): 'bottomright'}
    for (yy, hh, rp) in ys:
        for (xx, ww, cp) in xs:
            edge = grid[(rp, cp)]
            eid = f'{base}-{status}' if edge is None else f'{base}-{status}-{edge}'
            extra = ''
            if edge is None and grip:
                # NeXT knob: a small recessed indentation across the centre
                if grip == 'v':                 # vertical bar (slider handle)
                    gx = xx + ww / 2
                    extra = (f'<rect x="{gx-1:.1f}" y="{yy+2}" width="1" height="{hh-4}" fill="#5c5e60"/>'
                             f'<rect x="{gx:.1f}" y="{yy+2}" width="1" height="{hh-4}" fill="#ffffff"/>')
                else:                           # horizontal bar (scrollbar knob)
                    gy = yy + hh / 2
                    extra = (f'<rect x="{xx+2}" y="{gy-1:.1f}" width="{ww-4}" height="1" fill="#5c5e60"/>'
                             f'<rect x="{xx+2}" y="{gy:.1f}" width="{ww-4}" height="1" fill="#ffffff"/>')
            els.append(f'<g id="{eid}">{region(xx, yy, ww, hh, rp, cp, fill, frame, raised, grained)}{extra}</g>')

def indicator(base, status, draw, size=16):
    oy = _y[0]; ox = 4; _y[0] += size + 6
    els.append(f'<g id="{base}-{status}"><rect x="{ox}" y="{oy}" width="{size}" height="{size}" fill="#000000" fill-opacity="0"/>{draw(ox, oy, size)}</g>')

# framed widgets: (base, [(status, fill, frame, raised)])
FR = {
    'button': [('normal', '#9a9d9f', FRAME, True), ('focused', '#b6b6b6', BLUE, True),
               ('pressed', '#82858a', FRAME, False), ('toggled', '#8fa0ac', FRAME, False),
               ('disabled', '#b3b6b8', '#82858a', True)],
    'lineedit': [('normal', '#ffffff', FRAME, False), ('focused', '#ffffff', BLUE, False),
                 ('pressed', '#ffffff', FRAME, False), ('toggled', '#ffffff', FRAME, False),
                 ('disabled', '#e6e6e6', '#82858a', False)],
    'menu':    [('normal', '#9a9d9f', FRAME, True)],
    'tooltip': [('normal', '#cac8c2', FRAME, True)],
    'frame':   [('normal', '#9a9d9f', FRAME, False)],
    'toolbar': [('normal', '#8f9294', FRAME, True)],
    'group':   [('normal', '#9a9d9f', FRAME, False)],
    'progressbar':  [('normal', 'url(#mgroove)', FRAME, False)],
    'progress':     [('normal', 'url(#prog)', FRAME, True)],
    'slidergroove': [('normal', '#7a7d7f', FRAME, False)],
    'slidercursor': [('normal', '#9a9d9f', FRAME, True), ('focused', '#b6b6b6', BLUE, True),
                     ('pressed', '#82858a', FRAME, False), ('disabled', '#b3b6b8', '#82858a', True)],
    'scrollbargroove': [('normal', '#828587', FRAME, False)],
    'scrollbarcursor': [('normal', '#9a9d9f', FRAME, True), ('focused', '#b6b6b6', BLUE, True),
                        ('pressed', '#82858a', FRAME, False), ('disabled', '#b3b6b8', '#82858a', True)],
    'focus':   [('normal', '#00000000', BLUE, True)],
}
for base, sts in FR.items():
    # progress/progressbar fills stay smooth (already gradients, so region()
    # skips grain on them automatically via the sheen_fill guard). lineedit is
    # a content area (white, typed-in text) -- same as qstyle's PE_PanelLineEdit,
    # it stays flat, no metal sheen/grain, only the chrome gets brushed.
    grained = base != 'lineedit'
    for (status, fill, frame, raised) in sts:
        g = 'h' if base == 'scrollbarcursor' else ('v' if base == 'slidercursor' else False)  # h dimple scroller, v slider
        framed(base, status, fill, frame, raised, grip=g, grained=grained)
        # inactive duplicate so widgets don't blank on unfocused windows
        if status in ('normal', 'focused', 'pressed', 'toggled'):
            framed(base, status + '-inactive', fill, frame, raised, grip=g, grained=grained)

# checkbox: recessed white box, check when checked
def cb(checked):
    def d(ox, oy, s):
        r = [f'<rect x="{ox+1}" y="{oy+1}" width="{s-2}" height="{s-2}" fill="#ffffff" stroke="#1a1a1a" stroke-width="1"/>',
             f'<rect x="{ox+2}" y="{oy+2}" width="{s-4}" height="1" fill="#7a7c7e"/>',
             f'<rect x="{ox+2}" y="{oy+2}" width="1" height="{s-4}" fill="#7a7c7e"/>']
        if checked:
            r.append(f'<path d="M{ox+3.5} {oy+s/2} L{ox+s*0.45} {oy+s-4} L{ox+s-3} {oy+3.5}" fill="none" stroke="#4a7a3a" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>')
        return ''.join(r)
    return d
def rb(checked):
    def d(ox, oy, s):
        cx, cy, rr = ox + s / 2, oy + s / 2, s / 2 - 1
        r = [f'<circle cx="{cx}" cy="{cy}" r="{rr}" fill="#ffffff" stroke="#1a1a1a" stroke-width="1"/>',
             f'<path d="M{cx-rr*0.7} {cy-rr*0.7} A {rr} {rr} 0 0 1 {cx+rr*0.7} {cy-rr*0.7}" fill="none" stroke="#7a7c7e" stroke-width="1"/>']
        if checked:
            r.append(f'<circle cx="{cx}" cy="{cy}" r="{rr*0.5}" fill="#223f53"/>')
        return ''.join(r)
    return d
for st in ('normal', 'focused', 'pressed', 'disabled', 'normal-inactive'):
    indicator('checkbox', 'checked-' + st, cb(True), 16)
    indicator('checkbox', 'unchecked-' + st, cb(False), 16)
    indicator('radio', 'checked-' + st, rb(True), 16)
    indicator('radio', 'unchecked-' + st, rb(False), 16)

# arrow indicators (scrollbars, spin boxes, combos, menus) — solid NeXT triangles
def arrow(direction, col):
    def d(ox, oy, s):
        m = 4
        pts = {
            'up':    [(ox+s/2, oy+m), (ox+m, oy+s-m), (ox+s-m, oy+s-m)],
            'down':  [(ox+m, oy+m), (ox+s-m, oy+m), (ox+s/2, oy+s-m)],
            'left':  [(ox+s-m, oy+m), (ox+s-m, oy+s-m), (ox+m, oy+s/2)],
            'right': [(ox+m, oy+m), (ox+m, oy+s-m), (ox+s-m, oy+s/2)],
        }[direction]
        p = ' '.join(f'{x:.1f},{y:.1f}' for x, y in pts)
        return f'<polygon points="{p}" fill="{col}"/>'
    return d
ARROW_COL = {'normal': '#1a1a1a', 'focused': '#1a1a1a', 'pressed': '#1a1a1a',
             'disabled': '#a9a9a9', 'normal-inactive': '#696969'}
for d in ('up', 'down', 'left', 'right'):
    for st, col in ARROW_COL.items():
        indicator('arrow-' + d, st, arrow(d, col), 16)

# combo-box dropdown indicator: a recessed inset well holds the arrow, so a
# dropdown is clearly distinct from a (uniformly raised) push button.
def combo_arrow(direction, col):
    WELL, ITL, IBR, FR = '#828587', '#5c5e60', '#ffffff', '#1a1a1a'
    def d(ox, oy, s):
        r = [f'<rect x="{ox}" y="{oy}" width="{s}" height="{s}" fill="{WELL}" stroke="{FR}" stroke-width="1"/>',
             f'<rect x="{ox+1}" y="{oy+1}" width="{s-2}" height="1" fill="{ITL}"/>',
             f'<rect x="{ox+1}" y="{oy+1}" width="1" height="{s-2}" fill="{ITL}"/>',
             f'<rect x="{ox+1}" y="{oy+s-2}" width="{s-2}" height="1" fill="{IBR}"/>',
             f'<rect x="{ox+s-2}" y="{oy+1}" width="1" height="{s-2}" fill="{IBR}"/>']
        m = 5
        pts = ([(ox+m, oy+m+1), (ox+s-m, oy+m+1), (ox+s/2, oy+s-m)] if direction == 'down'
               else [(ox+s/2, oy+m), (ox+m, oy+s-m-1), (ox+s-m, oy+s-m-1)])
        r.append('<polygon points="%s" fill="%s"/>' % (' '.join(f'{x:.1f},{y:.1f}' for x, y in pts), col))
        return ''.join(r)
    return d
COMBO_ARROW_COL = {'normal': '#1a1a1a', 'focused': '#1a1a1a', 'pressed': '#1a1a1a',
                   'disabled': '#a9a9a9', 'normal-inactive': '#696969'}
for d in ('down', 'up'):
    for st, col in COMBO_ARROW_COL.items():
        indicator('combo-' + d, st, combo_arrow(d, col), 16)

_defs.append('<linearGradient id="prog" x1="0" y1="0" x2="0" y2="1">'
             '<stop offset="0" stop-color="#a3c9e5"/><stop offset="0.12" stop-color="#cee4f3"/>'
             '<stop offset="0.5" stop-color="#487697"/><stop offset="0.54" stop-color="#426f8f"/>'
             '<stop offset="0.9" stop-color="#315773"/><stop offset="1" stop-color="#223f53"/></linearGradient>')
_defs.append('<linearGradient id="mgroove" x1="0" y1="0" x2="0" y2="1">'
             '<stop offset="0" stop-color="#6b6e70"/><stop offset="0.18" stop-color="#9a9d9f"/>'
             '<stop offset="0.55" stop-color="#7e8082"/><stop offset="1" stop-color="#8c8f91"/></linearGradient>')

svg = ('<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n'
       f'<svg xmlns="http://www.w3.org/2000/svg" width="80" height="{_y[0]+8}" viewBox="0 0 80 {_y[0]+8}">\n  '
       '<defs>' + ''.join(_defs) + '</defs>\n  ' + '\n  '.join(els) + '\n</svg>\n')
os.makedirs(OUT, exist_ok=True)
open(os.path.join(OUT, 'TenshiSTEP-zirconium.svg'), 'w').write(svg)
print(f"generated Kvantum SVG with {len(els)} elements, {len(_defs)} gradient defs")
