.pragma library

// Pure quack-statistics logic: no QML, no DMS services, so it can be tested
// with node. Stats are stored as one object in the plugin *state*
// (pluginService.savePluginState("duck", "stats", ...)), not in settings.

const KEEP_DAYS = 90 // per-day history older than this is dropped

function emptyStats() {
    return {
        total: 0,
        daily: {},          // { "2026-10-09": 12, ... } in local time
        lastQuack: ""
    }
}

// Accepts whatever was loaded from disk and fills in missing fields, so old
// or hand-edited state files can't break the widget.
function normalize(raw) {
    const s = emptyStats()
    if (!raw || typeof raw !== "object")
        return s
    s.total = Number.isInteger(raw.total) && raw.total > 0 ? raw.total : 0
    if (raw.daily && typeof raw.daily === "object")
        for (const day in raw.daily)
            if (Number.isInteger(raw.daily[day]) && raw.daily[day] > 0)
                s.daily[day] = raw.daily[day]
    s.lastQuack = typeof raw.lastQuack === "string" ? raw.lastQuack : ""
    return s
}

function dayKey(date) {
    const pad = n => (n < 10 ? "0" : "") + n
    return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate())
}

function addDays(date, n) {
    const d = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    d.setDate(d.getDate() + n)
    return d
}

// Consecutive days with at least one quack, ending today. If you haven't
// quacked yet today, a streak ending yesterday still counts (it's not lost
// until the day is over).
function streak(stats, now) {
    let day = (stats.daily[dayKey(now)] || 0) > 0 ? now : addDays(now, -1)
    let count = 0
    while ((stats.daily[dayKey(day)] || 0) > 0) {
        count++
        day = addDays(day, -1)
    }
    return count
}

function summary(stats, now) {
    return {
        total: stats.total,
        today: stats.daily[dayKey(now)] || 0,
        streak: streak(stats, now),
        lastQuack: stats.lastQuack
    }
}

// Returns a new stats object with one more quack. Never mutates the input:
// the object loaded from PluginService is its cached copy.
function record(stats, text, now) {
    const s = normalize(stats)
    const today = dayKey(now)
    s.total += 1
    s.daily[today] = (s.daily[today] || 0) + 1
    s.lastQuack = text
    const oldest = dayKey(addDays(now, -KEEP_DAYS))
    for (const day in s.daily)
        if (day < oldest)
            delete s.daily[day]
    return s
}
