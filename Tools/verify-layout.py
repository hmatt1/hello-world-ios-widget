#!/usr/bin/env python3
"""Check the layout invariants the widget relies on.

BoardGrid.resolve is pure arithmetic, so it can be re-derived here and checked
exhaustively without a simulator. Run this after changing anything in
Shared/BoardGrid.swift or Shared/Theme.swift.

    python3 Tools/verify-layout.py

It asserts, across every family, shortcut count, density, published iPhone
widget canvas and a range of name lengths:

  1. no tile is ever narrower or shorter than the 44pt minimum touch target
  2. the text style chosen for a board still fits on every device, not just on
     the smallest canvas the resolver clamps against
  3. outer padding and the gap between tiles are both non-decreasing as
     Density rises, so a looser setting never draws a tighter board
  4. every accent in every theme clears 4.5:1 against that theme's label

Keep the constants below in step with the Swift. They are duplicated on
purpose: a check that imports the thing it is checking cannot catch a wrong
constant.
"""

import math
import sys

MINIMUM_TARGET = 44.0

# BoardSize.capacity
CAPACITY = {"small": 4, "medium": 6, "large": 12}

# BoardSize.canvas, the 320x568pt layout
CANVAS = {"small": (141, 141), "medium": (291, 141), "large": (291, 299)}

# Every iPhone widget canvas row Apple publishes, smallest first.
DEVICES = {
    "small": [(141, 141), (148, 148), (155, 155), (158, 158), (162, 162), (169, 169), (170, 170)],
    "medium": [(291, 141), (321, 148), (329, 155), (338, 158), (344, 162), (360, 169), (364, 170)],
    "large": [(291, 299), (321, 324), (329, 345), (338, 354), (344, 366), (360, 379), (364, 382)],
}

# Density: (padding, gap)
DENSITIES = [("edge", 0.0, 0.0), ("compact", 4.0, 8.0), ("roomy", 12.0, 12.0)]

# BoardGrid.ladder
LADDER = [
    ("largeTitle", 34.0), ("title", 28.0), ("title2", 22.0), ("title3", 20.0),
    ("headline", 17.0), ("subheadline", 15.0), ("footnote", 13.0), ("caption", 12.0),
]

# TileMode.inset and TileMode.lineLimit
INSET = {"row": 28.0, "tile": 12.0}
LINE_LIMIT = {"row": 2, "tile": 3}

# Theme.spec: accents and label, as 0xRRGGBB
THEMES = {
    "ink": ([], 0xF5F5F7),
    "paper": ([], 0x111014),
    "midnight": ([0x3B5BDB, 0x1971C2, 0x5F3DC4, 0x7048B6, 0xC2255C, 0x2C5FA8], 0xFFFFFF),
    "aurora": ([0x0B7A5B, 0x2B7A3F, 0x557A0B, 0x0E7490, 0x0F766E, 0x4D7C0F], 0xFFFFFF),
    "sunset": ([0xC92A2A, 0xC2410C, 0xA9346B, 0x862E9C, 0x364FC7, 0x8F5B10], 0xFFFFFF),
}


def balanced(slots):
    return {4: 2, 5: 3, 6: 3, 7: 4, 8: 4, 9: 3}.get(slots, 4)


def column_count(slots, size):
    if slots <= 1:
        return 1
    if size == "small":
        return 1 if slots <= 3 else 2
    if size == "medium":
        return slots if slots <= 3 else (2 if slots == 4 else 3)
    return 1 if slots <= 3 else balanced(slots)


def spacing(rows, padding_pref, gap_pref, canvas_height):
    """Slack goes to separation first, then to outer padding."""
    slack = max(0.0, canvas_height - MINIMUM_TARGET * rows)
    if rows > 1:
        gap_budget = min(gap_pref * (rows - 1), slack)
        return gap_budget / (rows - 1), min(padding_pref, max(0.0, slack - gap_budget) / 2)
    return gap_pref, min(padding_pref, slack / 2)


def text_style(cell_w, cell_h, mode, longest_name):
    width = max(1.0, cell_w - INSET[mode])
    characters = float(max(4, longest_name))
    lines = float(LINE_LIMIT[mode])
    for name, points in LADDER:
        needed = points * 0.55 * characters
        used = min(lines, max(1.0, math.ceil(needed / width)))
        if used <= lines and needed <= width * lines and cell_h >= points * 1.25 * used + 6:
            return name, points, used
    return "caption", 12.0, lines


def relative_luminance(hex_value):
    def channel(component):
        component /= 255.0
        return component / 12.92 if component <= 0.03928 else ((component + 0.055) / 1.055) ** 2.4

    return (0.2126 * channel((hex_value >> 16) & 0xFF)
            + 0.7152 * channel((hex_value >> 8) & 0xFF)
            + 0.0722 * channel(hex_value & 0xFF))


def contrast(a, b):
    high, low = sorted((relative_luminance(a), relative_luminance(b)), reverse=True)
    return (high + 0.05) / (low + 0.05)


def main():
    failures = []
    checks = 0

    for name_length in (4, 6, 10, 15, 20, 26):
        for size, capacity in CAPACITY.items():
            for slots in range(1, capacity + 1):
                columns = column_count(slots, size)
                rows = math.ceil(slots / columns)
                mode = "row" if columns == 1 and slots > 1 else "tile"

                gaps, paddings = [], []
                for density, padding_pref, gap_pref in DENSITIES:
                    gap, padding = spacing(rows, padding_pref, gap_pref, CANVAS[size][1])
                    gaps.append(gap)
                    paddings.append(padding)

                    floor_w, floor_h = CANVAS[size]
                    cell_w = (floor_w - 2 * padding - gap * (columns - 1)) / columns
                    cell_h = (floor_h - 2 * padding - gap * (rows - 1)) / rows
                    style, points, used = text_style(cell_w, cell_h, mode, name_length)

                    for device_w, device_h in DEVICES[size]:
                        checks += 1
                        w = (device_w - 2 * padding - gap * (columns - 1)) / columns
                        h = (device_h - 2 * padding - gap * (rows - 1)) / rows
                        where = f"{size}/{slots}/{density}/{device_w}x{device_h}/{name_length}ch"
                        if w < MINIMUM_TARGET - 0.05 or h < MINIMUM_TARGET - 0.05:
                            failures.append(f"touch target {where}: {w:.1f}x{h:.1f}")
                        if h < points * 1.25 * used + 6 - 0.01:
                            failures.append(f"{style} does not fit {where}: {h:.1f}pt tall")
                        if text_style(w, h, mode, name_length)[1] < points:
                            failures.append(f"{style} too large for {where}")

                if not gaps[0] <= gaps[1] <= gaps[2] + 1e-9:
                    failures.append(f"gap not monotone at {size}/{slots}: {gaps}")
                if not paddings[0] <= paddings[1] <= paddings[2] + 1e-9:
                    failures.append(f"padding not monotone at {size}/{slots}: {paddings}")

    for theme, (accents, label) in THEMES.items():
        for accent in accents:
            checks += 1
            ratio = contrast(accent, label)
            if ratio < 4.5:
                failures.append(f"{theme} #{accent:06X} is {ratio:.2f}:1 against its label")

    print(f"{checks} checks")
    for failure in failures:
        print(f"  FAIL {failure}")
    if failures:
        print(f"{len(failures)} failed")
        return 1
    print("all invariants hold")
    return 0


if __name__ == "__main__":
    sys.exit(main())
