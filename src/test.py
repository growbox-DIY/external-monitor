# test.py - checks the wiring and display variant, without WiFi:
#   mpremote connect /dev/cu.usbmodem21101 cp src/config.py src/st7735.py :
#   mpremote connect /dev/cu.usbmodem21101 run src/test.py
#
# You should see: a white frame exactly on the edges, TOP
# at the top and RED / GREEN / BLUE bars in those colours.
# - red and blue swapped -> TFT_BGR = True
# - text upside down -> flip TFT_FLIP
# - frame cut off or garbage at the edge -> TFT_X_OFFSET / TFT_Y_OFFSET (2, 1)
# - colours inverted -> TFT_INVERT = True
from machine import PWM, SPI, Pin

import config
from st7735 import ST7735


def rgb(r, g, b):
    c = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
    return ((c & 0xFF) << 8) | (c >> 8)


spi = SPI(1, baudrate=config.SPI_BAUDRATE, sck=Pin(config.PIN_SCK),
          mosi=Pin(config.PIN_MOSI), miso=Pin(config.PIN_MISO))
tft = ST7735(spi, config.PIN_CS, config.PIN_DC, config.PIN_RST,
             x_offset=config.TFT_X_OFFSET, y_offset=config.TFT_Y_OFFSET,
             bgr=config.TFT_BGR, flip=config.TFT_FLIP, invert=config.TFT_INVERT)

if config.PIN_LED is not None:
    PWM(Pin(config.PIN_LED), freq=1000).duty_u16(65535)

WHITE = rgb(255, 255, 255)
tft.fill(rgb(0, 0, 0))
tft.rect(0, 0, 128, 160, WHITE)
tft.text("TOP", 52, 8, WHITE)

for i, (name, color) in enumerate((
        ("RED", rgb(255, 0, 0)),
        ("GREEN", rgb(0, 255, 0)),
        ("BLUE", rgb(0, 0, 255)),
)):
    y = 30 + i * 40
    tft.fill_rect(8, y, 112, 28, color)
    tft.text(name, 64 - len(name) * 4, y + 10, rgb(0, 0, 0))

tft.show()
print("test screen drawn")
