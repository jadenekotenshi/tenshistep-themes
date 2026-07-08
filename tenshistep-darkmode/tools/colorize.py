#!/usr/bin/env python3
"""
Colorize the TenshiSTEP-darkmode icon theme with an OPENSTEP 4.2-inspired palette.

Strategy: the icons are drawn from a tight grayscale vocabulary
(#b0b0b0 body, #6e6e6e bevel-shadow, #9a9a9a secondary, #1a1a1a outline,
#ffffff highlight). We remap the *body/shadow* grays per icon category to a
muted, slightly-desaturated colour, while keeping the #1a1a1a outlines and
#ffffff highlights untouched -- so the chiselled NeXT bevel survives and only
the "material" of each object gains colour. A handful of icons then get
semantic accent overrides (OK=green, error/close/record=red, battery levels,
office-app headers, per-language source bands, ...).

Run against the ORIGINAL grayscale icons (restore them from git first if
re-tuning). Operates in place on real .svg files; symlink aliases inherit the
colour of their target automatically.
"""
import os, re, sys

ICONS = os.path.join(os.path.dirname(__file__), '..', 'icons', 'TenshiSTEP-darkmode')

# --- OPENSTEP-muted palette -------------------------------------------------
GOLD, STEEL, BLUE  = '#d3b64f', '#9cafc4', '#4a3fa0'
GREEN, RED, AMBER  = '#6ba85d', '#c25a4d', '#d59a3c'
SILVER, TAN, TERRA = '#b6bdc8', '#d7c286', '#c1724a'
CLOUD, MOON        = '#ccd4da', '#c3ccd6'
TEAL, PLUM, SLATE  = '#4f9a95', '#8a6fa6', '#2e2768'

def _hx(c): return tuple(int(c[i:i+2], 16) for i in (1, 3, 5))
def _hs(t): return '#%02x%02x%02x' % t
def shade(c, f): r, g, b = _hx(c); return _hs((int(r*f), int(g*f), int(b*f)))
def light(c, f): r, g, b = _hx(c); return _hs((int(r+(255-r)*f), int(g+(255-g)*f), int(b+(255-b)*f)))

def body_remap(base):
    """Map the neutral body/shadow grays onto a colour while keeping bevel."""
    return {
        '#b0b0b0': base,
        '#9a9a9a': shade(base, 0.85),
        '#6e6e6e': shade(base, 0.60),
        '#c2c2c2': light(base, 0.14),
        '#bcbcbc': light(base, 0.10),
        '#aaaaaa': shade(base, 0.94),
    }

# --- per-icon category tint (first match wins); value is a base colour ------
TINT_RULES = [
    (r'^weather-clear-night', MOON),
    (r'^weather-clear', GOLD),
    (r'^weather-', CLOUD),
    (r'^folder', GOLD),
    (r'^user-home', TAN),
    (r'^user-trash', GREEN),
    (r'^(drive-optical|media-optical|application-x-cd-image|application-x-iso)', SILVER),
    (r'^network-workgroup', BLUE),
    (r'^network-server', STEEL),
    (r'^network-wired', BLUE),
    (r'^network-vpn', BLUE),
    (r'^(drive-harddisk|drive-removable|media-flash|media-sdcard)', STEEL),
    (r'^(computer|phone|laptop|user-desktop)', STEEL),
    (r'^(input-keyboard|input-mouse|input-tablet|input-gaming|input-touchpad|scanner|camera|printer|uninterruptible|audio-headphones|preferences-desktop-keyboard|keyboard-layout)', STEEL),
    (r'^dialog-error', RED),
    (r'^dialog-warning', AMBER),
    (r'^(dialog-information|dialog-question)', BLUE),
    (r'^system-lock-screen', GOLD),
    (r'^user-away', AMBER),
    (r'^emblem-favorite', GOLD),
    (r'^emblem-mounted', GREEN),
    (r'^emblem-locked', GOLD),
    (r'^emblem-shared', BLUE),
    (r'^brightness', GOLD),
    (r'^audio-volume', STEEL),
    (r'^start-here-kde', BLUE),
    (r'^view-app-grid', STEEL),
    (r'^image-x-generic', TAN),
    (r'^video-x-generic', STEEL),
    (r'^package-x-generic', TAN),
    (r'^(text-x-generic|text-html|application-x-shellscript|font-x-generic|application-pdf|text-x-source|application-x-generic)', STEEL),
    (r'^help-browser', BLUE),
    (r'^mail-client', BLUE),
]

GAMES = {'steam', 'ffxiv', 'guildwars2', 'doom'}

# --- accent overrides (all matching rules applied, after tinting) -----------
ACCENT_RULES = [
    (r'^application-pdf\.svg$',            [('#2a2a2a', RED)]),
    (r'^audio-x-generic\.svg$',           [('#1a1a1a', BLUE)]),
    (r'^x-office-document\.svg$',         [('#3a3a3a', BLUE)]),
    (r'^x-office-spreadsheet\.svg$',      [('#3a3a3a', GREEN)]),
    (r'^x-office-presentation\.svg$',     [('#3a3a3a', TERRA)]),
    (r'^x-office-calendar\.svg$',         [('#3a3a3a', RED)]),
    (r'^dialog-ok\.svg$',                 [('#1a1a1a', GREEN)]),
    (r'^dialog-cancel\.svg$',             [('#1a1a1a', RED)]),
    (r'^list-add\.svg$',                  [('#1a1a1a', GREEN)]),
    (r'^list-remove\.svg$',               [('#1a1a1a', RED)]),
    (r'^system-shutdown\.svg$',           [('#1a1a1a', RED)]),
    (r'^network-bluetooth\.svg$',         [('#1a1a1a', BLUE)]),
    (r'^media-record\.svg$',              [('#3a3a3a', RED)]),
    (r'^user-online\.svg$',               [('#2a2a2a', GREEN)]),
    (r'^user-busy\.svg$',                 [('#2a2a2a', RED)]),
    (r'^emblem-added\.svg$',              [('#2a2a2a', GREEN)]),
    (r'^emblem-removed\.svg$',            [('#2a2a2a', RED)]),
    (r'^emblem-default\.svg$',            [('#2a2a2a', GREEN)]),
    (r'^emblem-important\.svg$',          [('#3a3a3a', RED)]),
    (r'^emblem-modified\.svg$',           [('#3a3a3a', AMBER)]),
    (r'^battery-(full|good)(-charging)?\.svg$',    [('#3a3a3a', GREEN)]),
    (r'^battery-low(-charging)?\.svg$',            [('#3a3a3a', AMBER)]),
    (r'^battery-(caution|empty)(-charging)?\.svg$',[('#3a3a3a', RED)]),
    (r'^weather-showers',                 [('#41505c', BLUE)]),
    (r'^weather-storm\.svg$',             [('#3a3a3a', GOLD)]),
    (r'^weather-snow\.svg$',              [('#5a5a5a', '#948adf')]),
    (r'^utilities-terminal\.svg$',        [('#d0d0d0', '#8ada8a')]),
    (r'^system-file-manager\.svg$',       [('#d0d0d0', '#8ada8a')]),
]

SRC_BAND = {
    'text-x-python': BLUE, 'application-javascript': GOLD, 'text-x-typescript': BLUE,
    'application-json': SLATE, 'text-x-csrc': BLUE, 'text-x-c++src': BLUE,
    'text-x-java': RED, 'text-x-go': TEAL, 'text-rust': TERRA, 'text-x-ruby': RED,
    'application-x-php': PLUM, 'text-css': BLUE, 'text-markdown': SLATE,
    'application-xml': GREEN, 'application-x-yaml': GREEN, 'text-x-sql': TEAL,
}

def pick_tint(name, relpath):
    for pat, base in TINT_RULES:
        if re.match(pat, name):
            return base
    stem = name[:-4]
    if relpath.startswith('apps/') and stem not in GAMES and stem != 'application-menu':
        return STEEL
    return None

def main():
    changed = 0
    for root, _, files in os.walk(ICONS):
        for fn in files:
            if not fn.endswith('.svg'):
                continue
            path = os.path.join(root, fn)
            if os.path.islink(path):
                continue
            rel = os.path.relpath(path, ICONS)
            text = orig = open(path).read()

            stem = fn[:-4]
            if stem in SRC_BAND:                      # per-language source band
                text = text.replace('#2a2a2a', SRC_BAND[stem])
            else:
                base = pick_tint(fn, rel)
                if base:
                    for k, v in body_remap(base).items():
                        text = text.replace(k, v)

            for pat, pairs in ACCENT_RULES:           # semantic accents
                if re.match(pat, fn):
                    for old, new in pairs:
                        text = text.replace(old, new)

            if text != orig:
                open(path, 'w').write(text)
                changed += 1
    print(f"colorized {changed} icons")

if __name__ == '__main__':
    main()
