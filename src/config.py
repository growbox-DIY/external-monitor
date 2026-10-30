# config.py - monitor settings (no passwords: those are in secrets.py)

# --- ESP32-C3 SuperMini pins -> display ---
# avoid GPIO 2, 8, 9 (C3 strapping pins; 8 is also the onboard LED)
PIN_SCK = 4  # SCK
PIN_MOSI = 6  # SDA
PIN_MISO = 5  # unused, but SPI wants some pin - otherwise it would take GPIO 2
PIN_CS = 7  # CS
PIN_DC = 3  # A0
PIN_RST = 10  # RESET
PIN_LED = 1  # LED (backlight, PWM); None = LED wired permanently to 3V3
SPI_BAUDRATE = 26_000_000

# --- module variant (check with test.py) ---
# colours swapped (red instead of blue) -> TFT_BGR = True
TFT_BGR = False
# image upside down -> change TFT_FLIP
TFT_FLIP = True
# garbage stripes at the edge -> offset, usually (2, 1) or (0, 0)
TFT_X_OFFSET = 0
TFT_Y_OFFSET = 0
# negative -> True
TFT_INVERT = False

# --- GrowBox main ESP ---
ESP_HOST = "192.168.18.100"
# DHCP name of the main ESP; tried when the address stops responding
ESP_MDNS = "esp32.local"

# poll interval (s). The main ESP handles one request at a time and has little
# RAM, and the app and widget poll it too - hence less often than the widget (10 s).
POLL_CONFIG_S = 15
HTTP_TIMEOUT_S = 8
# after this many failed requests, look for the ESP at another address
FAILURES_BEFORE_SEARCH = 3

# --- backlight (0-100 %) ---
BACKLIGHT_DAY = 100
BACKLIGHT_NIGHT = 15
# night by the clock (local hours)
NIGHT_FROM = 22
NIGHT_TO = 7
