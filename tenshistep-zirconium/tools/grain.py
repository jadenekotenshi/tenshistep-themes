#!/usr/bin/env python3
"""
Shared brushed-metal grain generator, ported 1:1 from the qstyle C++
paintBrushedMetal() so every SVG-generated asset (Kvantum, Plasma Style)
uses the exact same texture language as the native-painted widgets:
irregular row spacing, variable opacity, streaks that don't run the full
width, and a slight consistent angle (~7 degrees) rather than dead-horizontal.
"""

GRAIN_SLOPE = 0.12  # ~7 degrees, matches qstyle's kGrainSlope


def grain_noise(seed):
    """Same xorshift hash as the C++ grainNoise() -- deterministic, stable."""
    x = seed & 0xFFFFFFFF
    x ^= (x << 13) & 0xFFFFFFFF
    x ^= (x >> 17)
    x ^= (x << 5) & 0xFFFFFFFF
    return (x & 0xFFFFFF) / float(0xFFFFFF)


def brushed_metal_lines(x, y, w, h, grain_seed):
    """Yield (x1, y1, x2, y2, color, alpha) for each grain streak in the rect,
    in local (0,0)-origin coordinates offset by (x, y)."""
    if w < 8 or h < 8:
        return
    x1, x2 = x + 1, x + w - 1
    if x2 <= x1:
        return
    row = y + 1
    bottom = y + h - 1
    while row < bottom:
        ry = row - y
        n1 = grain_noise(ry * 7 + grain_seed)
        n2 = grain_noise(ry * 13 + grain_seed + 91)
        n3 = grain_noise(ry * 31 + grain_seed + 233)
        step = 1 + int(n3 * 3.4)
        if n1 > 0.34:
            bright = n2 > 0.46
            alpha = (10 + int(n2 * 24)) if bright else (6 + int(n1 * 14))
            color = '#ffffff' if bright else '#000000'
            inset = int(w * 0.22)
            lx1 = x1 + int(grain_noise(ry * 17 + grain_seed + 5) * inset)
            lx2 = x2 - int(grain_noise(ry * 23 + grain_seed + 9) * inset)
            if lx2 > lx1:
                dy = round((lx2 - lx1) * GRAIN_SLOPE)
                yield (lx1, row, lx2, row + dy, color, alpha / 255.0)
        row += step


_clip_counter = [0]


def brushed_metal_svg(x, y, w, h, grain_seed):
    """Render the grain as a string of SVG <line> elements, clipped to the rect."""
    _clip_counter[0] += 1
    clip_id = f'gc{grain_seed & 0xffff}_{_clip_counter[0]}'
    out = [f'<clipPath id="{clip_id}"><rect x="{x+1}" y="{y+1}" width="{w-2}" height="{h-2}"/></clipPath>',
           f'<g clip-path="url(#{clip_id})">']
    for lx1, ly1, lx2, ly2, color, alpha in brushed_metal_lines(x, y, w, h, grain_seed):
        out.append(f'<line x1="{lx1}" y1="{ly1}" x2="{lx2}" y2="{ly2}" '
                    f'stroke="{color}" stroke-opacity="{alpha:.3f}"/>')
    out.append('</g>')
    return ''.join(out)


def metal_sheen_stops(base_hex):
    """Return the 5 gradient stops matching qstyle's metalSheen(), given a
    base hex colour, as a list of (offset, hex) tuples."""
    def hx(c):
        r = int(c[1:3], 16); g = int(c[3:5], 16); b = int(c[5:7], 16)
        return r, g, b

    def lighter(c, pct):
        r, g, b = hx(c)
        f = pct / 100.0
        return '#%02x%02x%02x' % (min(255, round(r * f)), min(255, round(g * f)), min(255, round(b * f)))

    def darker(c, pct):
        r, g, b = hx(c)
        f = 100.0 / pct
        return '#%02x%02x%02x' % (min(255, round(r * f)), min(255, round(g * f)), min(255, round(b * f)))

    return [
        (0.00, lighter(base_hex, 112)),
        (0.16, lighter(base_hex, 124)),
        (0.42, lighter(base_hex, 106)),
        (0.72, darker(base_hex, 103)),
        (1.00, darker(base_hex, 114)),
    ]


if __name__ == '__main__':
    # smoke test
    lines = list(brushed_metal_lines(0, 0, 40, 22, 40 * 131 + 22 * 977))
    print(f'{len(lines)} grain lines for a 40x22 rect')
    print(metal_sheen_stops('#9a9d9f'))
