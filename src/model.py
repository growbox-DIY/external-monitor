# model.py - ESP data -> `view` dict for ui.py. Same rules as the
# Mac widget (BoxModel.swift) and the app:
# - flowering week counted from midnight of the start day, max 10,
# - watering: 3rd day without watering yellow, 4th red.
#
# Time: "local" seconds since 2000-01-01 (no time zone), own
# conversions instead of utime.mktime - works the same on the ESP and in
# Python on a computer.

DAY = 86400
WEEK = 7 * DAY


# --- calendar ---

def _days(y, m, d):
    """Days since 2000-01-01 (days_from_civil algorithm)."""
    y -= m <= 2
    era = y // 400
    yoe = y - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468 - 10957


def epoch(y, m, d, hh=0, mm=0, ss=0):
    return _days(y, m, d) * DAY + hh * 3600 + mm * 60 + ss


def civil(t):
    """Seconds since 2000 -> (year, month, day, hour, min, sec)."""
    z = t // DAY + 10957 + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    y = yoe + era * 400 + (m <= 2)
    s = t % DAY
    return y, m, d, s // 3600, s // 60 % 60, s % 60


def format_local(t):
    return "%04d-%02d-%02d %02d:%02d:%02d" % civil(t)


def parse_local(s):
    """'YYYY-MM-DD[ HH:MM:SS]' (ESP local time) -> seconds or None."""
    try:
        y, m, d = int(s[0:4]), int(s[5:7]), int(s[8:10])
        hh = mm = ss = 0

        if len(s) >= 19:
            hh, mm, ss = int(s[11:13]), int(s[14:16]), int(s[17:19])

        return epoch(y, m, d, hh, mm, ss)
    except (ValueError, TypeError, IndexError):
        return None


def parse_iso_utc(s):
    """ISO from the app ('2026-10-08T17:12:33.123Z' or with +02:00) -> UTC seconds."""
    t = parse_local(s[:10] + " " + s[11:19]) if s and len(s) >= 19 else None

    if t is None:
        return None

    tail = s[19:]

    # fractions of a second
    while tail and tail[0] in ".0123456789":
        tail = tail[1:]

    if tail and tail[0] in "+-" and len(tail) >= 6:
        try:
            off = int(tail[1:3]) * 3600 + int(tail[4:6]) * 60
        except ValueError:
            off = 0

        t -= off if tail[0] == "+" else -off

    return t


def polish_utc_offset(t_utc):
    """UTC offset in Poland (s): CEST from the last Sunday of March
    01:00 UTC to the last Sunday of October 01:00 UTC."""
    y = civil(t_utc)[0]

    def last_sunday(m):
        d = 31
        # 2000-01-01 was a Saturday: (days + 6) % 7 == 0 -> Sunday
        while (_days(y, m, d) + 6) % 7 != 0:
            d -= 1
        return epoch(y, m, d, 1)

    return 7200 if last_sunday(3) <= t_utc < last_sunday(10) else 3600


# --- rules ---

def flowering_start(config):
    auto = config.get("auto") or {}

    if not auto.get("enabled"):
        return None

    started = auto.get("floweringStartedAt")

    if started:
        t = parse_local(started)
        if t is not None:
            return t

    day = auto.get("floweringStartDate")
    return parse_local(day) if day else None


def flowering_week(config, now):
    auto = config.get("auto") or {}
    day = auto.get("floweringStartDate")

    if not auto.get("enabled") or not day:
        return None

    start = parse_local(day)

    if start is None:
        return None

    elapsed = max(0, now - start)
    week = min(elapsed // WEEK + 1, 10)
    progress = 1.0 if elapsed >= 10 * WEEK else (elapsed % WEEK) / WEEK
    return week, progress


def feeding(config, now, utc_offset):
    feed = config.get("feeding") or {}
    times = [parse_iso_utc(s) for s in feed.get("history") or ()]
    times = [t + utc_offset for t in times if t is not None]

    if not times:
        last = feed.get("lastFedAt")
        t = parse_iso_utc(last) if last else None

        if t is None:
            return "overdue", "never", "water!"

        times = [t + utc_offset]

    days = now // DAY - max(times) // DAY

    if days >= 4:
        status, note = "overdue", "water!"
    elif days >= 3:
        status, note = "late", "water today"
    elif days == 2:
        status, note = "ok", "tomorrow"
    else:
        status, note = "ok", ""

    if days <= 0:
        label = "today"
    elif days == 1:
        label = "yesterday"
    else:
        label = "%d days ago" % days

    return status, label, note


def humidifier_state(config, status):
    hum = status.get("humidifier") or {}
    mode = "auto" if (config.get("auto") or {}).get("enabled") else "manual"
    band = (config.get("humidifier") or {}).get(mode) or {}

    if hum.get("on"):
        return "on"

    if not band.get("enabled"):
        return "off"

    return "idle" if hum.get("online") else "offline"


# --- view ---

def build(response, now, utc_offset, offline=False):
    """response: JSON from /api/config. now: local time (s since 2000) or
    None while the clock is not synced yet."""
    config = response.get("config") or {}
    sensor = response.get("sensor") or {}
    status = response.get("status") or {}

    fan_on = (config.get("relayFan") or {}).get("state") == 1
    level = max(0, min(100, status.get("fanLevel") or 0))

    view = {
        "offline": offline,
        "mode": status.get("mode"),
        "temp": sensor.get("temperature"),
        "hum": sensor.get("humidity"),
        "fan": (fan_on, level),
        "humidifier": humidifier_state(config, status),
    }

    if now is not None:
        view["week"] = flowering_week(config, now)
        view["feed"] = feeding(config, now, utc_offset)

    return view
