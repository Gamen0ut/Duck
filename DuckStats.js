.pragma library

// Pure quack-statistics logic: no QML, no DMS services, so it can be tested
// with node. Stats are stored as one object in the plugin *state*
// (pluginService.savePluginState("duck", "stats", ...)), not in settings.

const KEEP_DAYS = 90 // per-day history older than this is dropped

// `test(summary, now)` receives summary(stats, now) and the Date of the quack.
// `hidden: true` = secret: settings shows "???" until it's unlocked.
// `meta: true` = unlocked when every non-meta achievement is (no `test`). `var`, not `const`: only `var` is
// visible from QML as Stats.ACHIEVEMENTS.
var ACHIEVEMENTS = [
    // Milestones
    {id: "first",    icon: "🥚", name: "First quack",       description: "Quack once",                 test: s => s.total >= 1},
    {id: "q10",      icon: "🐣", name: "Chatty duckling",   description: "Quack 10 times",             test: s => s.total >= 10},
    {id: "q42",      icon: "🎲", name: "The answer",        description: "Quack 42 times",             test: s => s.total >= 42},
    {id: "q100",     icon: "🦆", name: "Seasoned quacker",  description: "Quack 100 times",            test: s => s.total >= 100},
    {id: "q666",     icon: "😈", name: "Devil's quack",     description: "Quack 666 times",            test: s => s.total >= 666},
    {id: "q1000",    icon: "👑", name: "Duck royalty",      description: "Quack 1000 times",           test: s => s.total >= 1000},
    {id: "q1337",    icon: "🕶️", name: "Leet quacker",      description: "Quack 1337 times",           test: s => s.total >= 1337},
    // Daily
    {id: "day25",    icon: "⚡", name: "Quack attack",      description: "Quack 25 times in one day",  test: s => s.today >= 25},
    {id: "day100",   icon: "🌪️", name: "Quack frenzy",      description: "Quack 100 times in one day", test: s => s.today >= 100},
    // Streaks (history keeps 90 days, so streaks above 91 can't be detected)
    {id: "streak3",  icon: "🔥", name: "On a roll",         description: "Quack 3 days in a row",      test: s => s.streak >= 3},
    {id: "streak7",  icon: "🏆", name: "Weekly waddle",     description: "Quack 7 days in a row",      test: s => s.streak >= 7},
    {id: "streak14", icon: "📅", name: "Fortnight flock",   description: "Quack 14 days in a row",     test: s => s.streak >= 14},
    {id: "streak30", icon: "🗓️", name: "Monthly migration", description: "Quack 30 days in a row",     test: s => s.streak >= 30},
    // Time of day
    {id: "nightOwl", icon: "🦉", name: "Night owl",         description: "Quack between 00:00 and 04:00", test: (s, now) => now.getHours() < 4},
    {id: "earlyBird", icon: "🐓", name: "Early bird",       description: "Quack between 05:00 and 07:00", test: (s, now) => now.getHours() >= 5 && now.getHours() < 7},
    // Calendar
    {id: "newYear",  icon: "🎆", name: "Happy new quack",   description: "Quack on January 1st",       test: (s, now) => onDate(now, 1, 1), hidden: true},
    {id: "valentine", icon: "💘", name: "Love quack",       description: "Quack on February 14th",     test: (s, now) => onDate(now, 2, 14), hidden: true},
    {id: "leapDay",  icon: "🐸", name: "Leap duck",         description: "Quack on February 29th",     test: (s, now) => onDate(now, 2, 29), hidden: true},
    {id: "halloween", icon: "🎃", name: "Spooky quack",     description: "Quack on October 31st",      test: (s, now) => onDate(now, 10, 31), hidden: true},
    {id: "christmas", icon: "🎄", name: "Jingle quack",     description: "Quack on December 25th",     test: (s, now) => onDate(now, 12, 25), hidden: true},
    // Meta
    {id: "completionist", icon: "🏅", name: "Completionist", description: "Unlock every other achievement", meta: true}
]

// month is 1-12 (Date.getMonth() is 0-11)
function onDate(date, month, day) {
    return date.getMonth() + 1 === month && date.getDate() === day
}

function emptyStats() {
    return {
        total: 0,
        daily: {},          // { "2026-10-09": 12, ... } in local time
        lastQuack: "",
        achievements: []    // ids of unlocked achievements
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
    if (Array.isArray(raw.achievements))
        s.achievements = raw.achievements.filter(id => ACHIEVEMENTS.some(a => a.id === id))
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

// Achievements whose condition is now met but that aren't unlocked yet.
// Meta achievements are checked last, counting what this quack unlocks, so
// Completionist arrives together with the last missing achievement.
function newlyUnlocked(stats, now) {
    const sum = summary(stats, now)
    const isNew = a => stats.achievements.indexOf(a.id) === -1
    const found = ACHIEVEMENTS.filter(a => !a.meta && isNew(a) && a.test(sum, now))
    const have = stats.achievements.concat(found.map(a => a.id))
    const allDone = ACHIEVEMENTS.every(a => a.meta || have.indexOf(a.id) !== -1)
    return found.concat(ACHIEVEMENTS.filter(a => a.meta && isNew(a) && allDone))
}

// Returns a new stats object with those achievements marked as unlocked.
function unlock(stats, achievements) {
    const s = normalize(stats)
    for (const a of achievements)
        if (s.achievements.indexOf(a.id) === -1)
            s.achievements.push(a.id)
    return s
}
