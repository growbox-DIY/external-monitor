# gen_wiring.py - draws docs/wiring.png (run on a computer, needs Pillow):
#   python3 tools/gen_wiring.py
import os

from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "wiring.png")
FONT = "/System/Library/Fonts/SFNS.ttf"

W, H = 1360, 1070
K = 2  # drawn at 2x, scaled down for smooth lines

BG = "#011515"
CARD = "#041C1B"
EDGE = "#123333"
TEXT = "#F2F5F4"
DIM = "#8FA3A0"
GREEN = "#00E95A"
CYAN = "#20DCE8"
BLUE = "#78BFFF"
YELLOW = "#FFD21C"
RED = "#FF6070"
ORANGE = "#FF9F43"
PURPLE = "#B48CFF"
GREY = "#7A8C8A"

img = Image.new("RGB", (W * K, H * K), BG)
d = ImageDraw.Draw(img)
_fonts = {}


def font(size, weight="Regular"):
    key = (size, weight)

    if key not in _fonts:
        f = ImageFont.truetype(FONT, size * K)
        f.set_variation_by_name(weight)
        _fonts[key] = f

    return _fonts[key]


def s(*v):
    return [x * K for x in v]


def text(x, y, t, size=20, weight="Regular", fill=TEXT, anchor="la"):
    d.text(s(x, y), t, font=font(size, weight), fill=fill, anchor=anchor)


def card(x0, y0, x1, y1, title, sub=None, right=False, accent=EDGE):
    d.rounded_rectangle(s(x0, y0, x1, y1), radius=22 * K, fill=CARD, outline=accent, width=2 * K)
    tx, anchor = (x1 - 22, "ra") if right else (x0 + 22, "la")
    text(tx, y0 + 20, title, 25, "Bold", anchor=anchor)

    if sub:
        text(tx, y0 + 54, sub, 15, fill=DIM, anchor=anchor)


def wire(points, color, width=4):
    d.line([c * K for p in points for c in p], fill=color, width=width * K, joint="curve")


def pin(x, y, color):
    r = 8
    d.ellipse(s(x - r, y - r, x + r, y + r), fill=CARD, outline=color, width=3 * K)


# header
text(60, 44, "GrowBox monitor wiring", 46, "Bold")
text(60, 104, "ESP32-C3 SuperMini · 1.8\" TFT ST7735 128×160 · SPI", 25, "Medium", CYAN)
text(60, 142, "Logical diagram, pin names as printed on the boards. GPIO numbers from "
     "src/config.py.", 17, fill=DIM)

# display pin -> ESP pin, top to bottom
rows = [
    ("VCC", "5V", RED),
    ("GND", "GND", GREY),
    ("CS", "GPIO 7", CYAN),
    ("RESET", "GPIO 10", PURPLE),
    ("A0 (DC)", "GPIO 3", YELLOW),
    ("SDA (MOSI)", "GPIO 6", BLUE),
    ("SCK", "GPIO 4", GREEN),
    ("LED", "GPIO 1", ORANGE),
]
TOP, STEP = 330, 62
LX, RX = 480, 900  # display card right edge, ESP card left edge

# --- cards ---
bottom = TOP + STEP * (len(rows) - 1) + 60
card(60, 210, LX, bottom, "TFT 1.8\" ST7735", "128×160 · own 3.3 V regulator · J1 open")

d.rounded_rectangle(s(1060, 196, 1140, 214), radius=6 * K, fill="#0E2A28", outline=EDGE, width=2 * K)
card(RX, 210, 1300, bottom, "ESP32-C3", "SuperMini · MicroPython", accent=GREEN)
text(1278, 640, "unused:", 15, fill=DIM, anchor="rm")
text(1278, 662, "GPIO 2, 8, 9 (boot)", 15, fill=DIM, anchor="rm")
text(1278, 684, "GPIO 5 (MISO, reserved)", 15, fill=DIM, anchor="rm")

# --- wires and labels ---
for i, (left, right, color) in enumerate(rows):
    y = TOP + STEP * i
    wire([(LX, y), (RX, y)], color)
    text(LX - 22, y, left, 19, "Semibold", color, anchor="rm")
    text(RX + 22, y, right, 20, "Semibold", color, anchor="lm")
    pin(LX, y, color)
    pin(RX, y, color)

# --- notes ---
notes = [
    "VCC goes to 5V: the display board has its own 3.3 V regulator. Leave the J1 jumper open "
    "(shorted is for 3.3 V only).",
    "LED on GPIO 1 lets the monitor dim the backlight at night. Wired to 3V3 it is always full; "
    "set PIN_LED = None then.",
    "GPIO 2, 8 and 9 are boot strapping pins on the C3. The SD card slot on the display board "
    "is not used.",
    "No wire to the main controller: the monitor reads it over WiFi (HTTP API).",
]
y = bottom + 60
for n in notes:
    d.ellipse(s(62, y + 7, 72, y + 17), fill=GREEN)
    text(86, y, n, 18)
    y += 44

img.resize((W, H), Image.LANCZOS).save(OUT)
print(OUT)
