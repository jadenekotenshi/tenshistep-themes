#!/usr/bin/env python3
"""
Generate the TenshiSTEP-darkmode Plasma Style (desktop theme) FrameSvg widgets:
NeXT chiselled bevels in the OPENSTEP palette. Each SVG carries the 9-slice
element ids (optionally prefixed by widget state) that Plasma's FrameSvg reads.
Plasma falls back to Breeze for any element/theme file not provided here.
"""
import os

OUT = os.path.join(os.path.dirname(__file__), '..', 'plasma', 'desktoptheme', 'TenshiSTEP-darkmode')

FRAME = '#1a1a1a'
BLUE = '#6a5fd6'

def region(ox, oy, w, h, rowpos, colpos, base, frame, raised):
    hi, sh = '#565d67', '#14161a'
    itl = hi if raised else '#101216'
    ibr = sh if raised else '#565d67'
    r = [f'<rect x="{ox}" y="{oy}" width="{w}" height="{h}" fill="{base}"/>']
    if rowpos == 'top':    r.append(f'<rect x="{ox}" y="{oy}" width="{w}" height="1" fill="{frame}"/>')
    if rowpos == 'bottom': r.append(f'<rect x="{ox}" y="{oy+h-1}" width="{w}" height="1" fill="{frame}"/>')
    if colpos == 'left':   r.append(f'<rect x="{ox}" y="{oy}" width="1" height="{h}" fill="{frame}"/>')
    if colpos == 'right':  r.append(f'<rect x="{ox+w-1}" y="{oy}" width="1" height="{h}" fill="{frame}"/>')
    if rowpos == 'top':    r.append(f'<rect x="{ox}" y="{oy+1}" width="{w}" height="1" fill="{itl}"/>')
    if colpos == 'left':   r.append(f'<rect x="{ox+1}" y="{oy}" width="1" height="{h}" fill="{itl}"/>')
    if rowpos == 'bottom': r.append(f'<rect x="{ox}" y="{oy+h-2}" width="{w}" height="1" fill="{ibr}"/>')
    if colpos == 'right':  r.append(f'<rect x="{ox+w-2}" y="{oy}" width="1" height="{h}" fill="{ibr}"/>')
    return r

def block(ox, oy, prefix, base, frame, raised, Wb=48, Hb=24, c=6):
    pre = (prefix + '-') if prefix else ''
    xs = [(ox, c, 'left'), (ox + c, Wb - 2 * c, 'mid'), (ox + Wb - c, c, 'right')]
    ys = [(oy, c, 'top'), (oy + c, Hb - 2 * c, 'mid'), (oy + Hb - c, c, 'bottom')]
    names = {('top', 'left'): 'topleft', ('top', 'mid'): 'top', ('top', 'right'): 'topright',
             ('mid', 'left'): 'left', ('mid', 'mid'): 'center', ('mid', 'right'): 'right',
             ('bottom', 'left'): 'bottomleft', ('bottom', 'mid'): 'bottom', ('bottom', 'right'): 'bottomright'}
    out = []
    for (yy, hh, rp) in ys:
        for (xx, ww, cp) in xs:
            nm = names[(rp, cp)]
            out.append(f'<g id="{pre}{nm}">' + ''.join(region(xx, yy, ww, hh, rp, cp, base, frame, raised)) + '</g>')
    return out

def combo_block(ox, oy, prefix, base, frame, raised, wellfill, itl, ibr, arrowcol):
    """A combobox FrameSvg: raised (or sunken) body with a recessed inset well
    baked into the right band, holding a down arrow — a NeXT pop-up button that
    reads clearly differently from a plain push button."""
    pre = (prefix + '-') if prefix else ''
    Wb, Hb, cl, cr, ct = 72, 28, 6, 26, 6
    cw = Wb - cl - cr
    ch = Hb - 2 * ct
    x0, x1, x2 = ox, ox + cl, ox + cl + cw
    y0, y1, y2 = oy, oy + ct, oy + ct + ch
    body = ''.join
    out = []
    cells = [('topleft', x0, y0, cl, ct, 'top', 'left'), ('top', x1, y0, cw, ct, 'top', 'mid'),
             ('left', x0, y1, cl, ch, 'mid', 'left'), ('center', x1, y1, cw, ch, 'mid', 'mid'),
             ('bottomleft', x0, y2, cl, ct, 'bottom', 'left'), ('bottom', x1, y2, cw, ct, 'bottom', 'mid')]
    for nm, xx, yy, ww, hh, rp, cp in cells:
        out.append(f'<g id="{pre}{nm}">' + body(region(xx, yy, ww, hh, rp, cp, base, frame, raised)) + '</g>')
    wx = x2 + 3; ww = cr - 7; wtop = oy + 4; wbot = oy + Hb - 4
    tr = body(region(x2, y0, cr, ct, 'top', 'right', base, frame, raised))
    tr += (f'<rect x="{wx}" y="{wtop}" width="{ww}" height="{y0+ct-wtop}" fill="{wellfill}"/>'
           f'<rect x="{wx}" y="{wtop}" width="{ww}" height="1" fill="{frame}"/>'
           f'<rect x="{wx+1}" y="{wtop+1}" width="{ww-2}" height="1" fill="{itl}"/>'
           f'<rect x="{wx}" y="{wtop}" width="1" height="{y0+ct-wtop}" fill="{frame}"/>'
           f'<rect x="{wx+ww-1}" y="{wtop}" width="1" height="{y0+ct-wtop}" fill="{frame}"/>')
    out.append(f'<g id="{pre}topright">{tr}</g>')
    acx = wx + ww / 2; acy = y1 + ch / 2; a = 4
    rc = body(region(x2, y1, cr, ch, 'mid', 'right', base, frame, raised))
    rc += (f'<rect x="{wx}" y="{y1}" width="{ww}" height="{ch}" fill="{wellfill}"/>'
           f'<rect x="{wx}" y="{y1}" width="1" height="{ch}" fill="{frame}"/>'
           f'<rect x="{wx+1}" y="{y1}" width="1" height="{ch}" fill="{itl}"/>'
           f'<rect x="{wx+ww-1}" y="{y1}" width="1" height="{ch}" fill="{frame}"/>'
           f'<rect x="{wx+ww-2}" y="{y1}" width="1" height="{ch}" fill="{ibr}"/>'
           f'<polygon points="{acx-a:.1f},{acy-2:.1f} {acx+a:.1f},{acy-2:.1f} {acx:.1f},{acy+3:.1f}" fill="{arrowcol}"/>')
    out.append(f'<g id="{pre}right">{rc}</g>')
    brc = body(region(x2, y2, cr, ct, 'bottom', 'right', base, frame, raised))
    brc += (f'<rect x="{wx}" y="{y2}" width="{ww}" height="{wbot-y2}" fill="{wellfill}"/>'
            f'<rect x="{wx}" y="{wbot-1}" width="{ww}" height="1" fill="{ibr}"/>'
            f'<rect x="{wx}" y="{y2}" width="1" height="{wbot-y2}" fill="{frame}"/>'
            f'<rect x="{wx+ww-1}" y="{y2}" width="1" height="{wbot-y2}" fill="{frame}"/>')
    out.append(f'<g id="{pre}bottomright">{brc}</g>')
    return out

def svg(elems, w, h):
    return (f'<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n  '
            + '\n  '.join(elems) + '\n</svg>\n')

def write(rel, text):
    p = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, 'w').write(text)

# --- widgets/button.svg : normal / hover / focus / pressed ---
b = []
b += block(4,   4, 'normal',  '#3b4048', FRAME, True)
b += block(4,  36, 'hover',   '#40454e', FRAME, True)
b += block(4,  68, 'focus',   '#b6b6b6', BLUE,  True)
b += block(4, 100, 'pressed', '#2c3138', FRAME, False)
write('widgets/button.svg', svg(b, 60, 132))

# --- widgets/combobox.svg : NeXT pop-up (raised body + recessed inset well) ---
cb = []
cb += combo_block(4,   4, 'normal',  '#3b4048', FRAME, True,  '#2f343b', '#14161a', '#565d67', '#cdd1d7')
cb += combo_block(4,  36, 'hover',   '#40454e', FRAME, True,  '#2f343b', '#14161a', '#565d67', '#cdd1d7')
cb += combo_block(4,  68, 'focus',   '#b6b6b6', BLUE,  True,  '#2f343b', '#14161a', '#565d67', '#cdd1d7')
cb += combo_block(4, 100, 'pressed', '#2c3138', FRAME, False, '#2f343b', '#14161a', '#565d67', '#cdd1d7')
write('widgets/combobox.svg', svg(cb, 84, 132))

# --- widgets/lineedit.svg : base / focus (recessed white) ---
le = []
le += block(4,  4, 'base',  '#202226', FRAME, False)
le += block(4, 36, 'focus', '#202226', BLUE,  False)
write('widgets/lineedit.svg', svg(le, 60, 68))

# --- single-prefix backgrounds (no state prefix) ---
write('widgets/panel-background.svg', svg(block(4, 4, '', '#2b2e34', FRAME, True, 64, 44, 8), 76, 56))
write('widgets/background.svg',       svg(block(4, 4, '', '#33373e', FRAME, True, 56, 40, 7), 68, 52))
write('dialogs/background.svg',       svg(block(4, 4, '', '#33373e', FRAME, True, 64, 44, 8), 76, 56))
write('widgets/tooltip.svg',          svg(block(4, 4, '', '#33373e', FRAME, True, 56, 36, 6), 68, 48))
write('widgets/listitem.svg',         svg(block(4, 4, '', '#3b4048', FRAME, True, 48, 24, 5), 60, 32))

# --- widgets/tabbar.svg : active tab (raised) + inactive tab (recessed) ---
tb = []
tb += block(4,  4, 'active-tab',   '#3b4048', FRAME, True)
tb += block(4, 36, 'inactive-tab', '#2c3138', FRAME, False)
write('widgets/tabbar.svg', svg(tb, 60, 68))

# --- widgets/scrollbar.svg : slider handle (raised) + groove trough (recessed) ---
sb = []
sb += block(4,  4, 'slider', '#3b4048', FRAME, True)
sb += block(4, 36, 'groove', '#2c3138', FRAME, False)
write('widgets/scrollbar.svg', svg(sb, 60, 68))

# --- widgets/slider.svg : groove track (recessed) + handle (raised) ---
sl = []
sl += block(4,  4, 'groove', '#2c3138', FRAME, False)
sl += block(4, 36, 'handle', '#3b4048', FRAME, True)
write('widgets/slider.svg', svg(sl, 60, 68))

# --- widgets/tasks.svg : task button normal / hover / focus / pressed ---
tk = []
tk += block(4,   4, 'normal',  '#3b4048', FRAME, True)
tk += block(4,  36, 'hover',   '#40454e', FRAME, True)
tk += block(4,  68, 'focus',   '#b6b6b6', BLUE,  True)
tk += block(4, 100, 'pressed', '#2c3138', FRAME, False)
write('widgets/tasks.svg', svg(tk, 60, 132))

# --- widgets/checkmarks.svg : checkbox tick + radiobutton dot ---
cm = [f'<g id="checkmark"><polyline points="3,8 6,11 13,4" fill="none" stroke="{BLUE}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></g>',
      f'<g id="radiobutton"><circle cx="24" cy="8" r="4" fill="{BLUE}"/></g>']
write('widgets/checkmarks.svg', svg(cm, 32, 16))

# --- dialogs/shutdowndialog.svg : plain beveled panel background ---
write('dialogs/shutdowndialog.svg', svg(block(4, 4, '', '#33373e', FRAME, True, 64, 44, 8), 76, 56))

print("generated Plasma Style SVGs under", os.path.relpath(OUT))
