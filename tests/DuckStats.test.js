// Unit tests for DuckStats.js. Run: node tests/DuckStats.test.js
const {assert, load, same, test} = require("./lib")
const S = load("DuckStats.js")

const d = s => new Date(s + "T12:00:00")
const ids = list => list.map(a => a.id)

test("dayKey uses local time and zero-pads", () => {
    assert.strictEqual(S.dayKey(new Date(2026, 0, 5)), "2026-01-05")
})

test("record counts total, today and last quack", () => {
    let s = S.normalize(null)
    s = S.record(s, "Quack!", d("2026-10-07"))
    s = S.record(s, "Quack!", d("2026-10-08"))
    s = S.record(s, "Hi", d("2026-10-09"))
    s = S.record(s, "Hi2", d("2026-10-09"))
    same(S.summary(s, d("2026-10-09")), {total: 4, today: 2, streak: 3, lastQuack: "Hi2", fed: 0})
})

test("streak survives until the day is over, then breaks", () => {
    let s = S.normalize(null)
    for (const day of ["2026-10-07", "2026-10-08", "2026-10-09"])
        s = S.record(s, "q", d(day))
    assert.strictEqual(S.streak(s, d("2026-10-10")), 3)
    assert.strictEqual(S.streak(s, d("2026-10-11")), 0)
})

test("record prunes days older than 90 days and never mutates its input", () => {
    let s = S.record(S.normalize(null), "q", d("2026-10-07"))
    const later = S.record(s, "q", d("2027-03-01"))
    assert.ok(!("2026-10-07" in later.daily))
    assert.strictEqual(later.total, 2)
    assert.strictEqual(s.total, 1)
})

test("normalize repairs bad or unknown data", () => {
    same(S.normalize({total: "bad", daily: {a: -1}}), S.emptyStats())
    same(S.normalize({achievements: ["first", "bogus"]}).achievements, ["first"])
})

test("achievements unlock once, in order", () => {
    let s = S.record(S.normalize(null), "q", d("2026-10-09"))
    same(ids(S.newlyUnlocked(s, d("2026-10-09"))), ["first"])
    s = S.unlock(s, S.newlyUnlocked(s, d("2026-10-09")), d("2026-10-09"))
    same(S.newlyUnlocked(s, d("2026-10-09")), [])
    for (let i = 0; i < 24; i++)
        s = S.record(s, "q", d("2026-10-09"))
    same(ids(S.newlyUnlocked(s, d("2026-10-09"))), ["q10", "day25"])
    s = S.unlock(s, S.newlyUnlocked(s, d("2026-10-09")), d("2026-10-09"))
    s = S.record(s, "q", d("2026-10-10"))
    s = S.record(s, "q", d("2026-10-11"))
    same(ids(S.newlyUnlocked(s, d("2026-10-11"))), ["streak3"])
})

// Quack `n` times on each of `days` consecutive days starting at `start`,
// unlocking achievements as the widget does. Returns the final stats.
function play(stats, start, days, n) {
    for (let day = 0; day < days; day++) {
        const now = new Date(start.getFullYear(), start.getMonth(), start.getDate() + day, 12)
        for (let i = 0; i < n; i++) {
            stats = S.record(stats, "q", now)
            stats = S.unlock(stats, S.newlyUnlocked(stats, now), now)
        }
    }
    return stats
}

test("milestones unlock exactly at their threshold", () => {
    for (const [id, total] of [["q42", 42], ["q666", 666], ["q1337", 1337]]) {
        const before = play(S.normalize(null), d("2026-01-01"), 1, total - 1)
        assert.ok(!before.achievements.includes(id), id + " too early")
        const at = play(before, d("2026-01-01"), 1, 1)
        assert.ok(at.achievements.includes(id), id + " not unlocked at " + total)
    }
})

test("Quack frenzy needs 100 quacks on the same day", () => {
    const spread = play(S.normalize(null), d("2026-01-01"), 2, 60)
    assert.ok(!spread.achievements.includes("day100"))
    assert.ok(play(S.normalize(null), d("2026-01-01"), 1, 100).achievements.includes("day100"))
})

test("14- and 30-day streaks unlock on the right day", () => {
    const s13 = play(S.normalize(null), d("2026-01-01"), 13, 1)
    assert.ok(!s13.achievements.includes("streak14"))
    const s14 = play(s13, d("2026-01-14"), 1, 1)
    assert.ok(s14.achievements.includes("streak14"))
    const s30 = play(s14, d("2026-01-15"), 16, 1)
    assert.ok(s30.achievements.includes("streak30"))
})

// One quack at an exact local date and time; returns the ids it unlocks.
function quackAt(year, month, day, hour, minute) {
    const now = new Date(year, month - 1, day, hour, minute || 0)
    return ids(S.newlyUnlocked(S.record(S.normalize(null), "q", now), now))
}

test("Night owl: 00:00 to 03:59 only", () => {
    assert.ok(quackAt(2026, 3, 3, 0, 0).includes("nightOwl"))
    assert.ok(quackAt(2026, 3, 3, 3, 59).includes("nightOwl"))
    assert.ok(!quackAt(2026, 3, 3, 4, 0).includes("nightOwl"))
    assert.ok(!quackAt(2026, 3, 3, 23, 59).includes("nightOwl"))
})

test("Early bird: 05:00 to 06:59 only", () => {
    assert.ok(!quackAt(2026, 3, 3, 4, 59).includes("earlyBird"))
    assert.ok(quackAt(2026, 3, 3, 5, 0).includes("earlyBird"))
    assert.ok(quackAt(2026, 3, 3, 6, 59).includes("earlyBird"))
    assert.ok(!quackAt(2026, 3, 3, 7, 0).includes("earlyBird"))
})

test("calendar achievements unlock on their day and not the day before", () => {
    for (const [id, y, m, day] of [["newYear", 2027, 1, 1], ["valentine", 2027, 2, 14], ["leapDay", 2028, 2, 29],
                                   ["halloween", 2026, 10, 31], ["christmas", 2026, 12, 25]]) {
        assert.ok(quackAt(y, m, day, 12).includes(id), id + " not unlocked on its day")
        const before = new Date(y, m - 1, day - 1, 12)
        assert.ok(!quackAt(before.getFullYear(), before.getMonth() + 1, before.getDate(), 12).includes(id), id + " unlocked a day early")
    }
})

test("calendar achievements are secret, the others are not", () => {
    const hidden = ids(S.ACHIEVEMENTS.filter(a => a.hidden))
    same(hidden, ["newYear", "valentine", "leapDay", "halloween", "christmas"])
})

test("Completionist unlocks together with the last missing achievement", () => {
    const others = ids(S.ACHIEVEMENTS.filter(a => !a.meta))
    const now = d("2026-03-03")
    // everything except "first"
    let s = S.normalize({achievements: others.filter(id => id !== "first")})
    s = S.record(s, "q", now)
    same(ids(S.newlyUnlocked(s, now)), ["first", "completionist"])
    // two missing: no Completionist yet
    s = S.normalize({achievements: others.filter(id => id !== "first" && id !== "christmas")})
    s = S.record(s, "q", now)
    same(ids(S.newlyUnlocked(s, now)), ["first"])
})

test("unlock records the date; old saves without dates still load", () => {
    const now = new Date(2026, 9, 9, 14, 30)
    const s = S.unlock(S.record(S.normalize(null), "q", now), [S.ACHIEVEMENTS[0]], now)
    same(s.unlockedAt, {first: now.getTime()})
    // a 0.3.0 save: ids only, no unlockedAt
    const old = S.normalize({total: 12, achievements: ["first", "q10"]})
    same(old.achievements, ["first", "q10"])
    same(old.unlockedAt, {})
    // garbage and dates of achievements that aren't unlocked are dropped
    same(S.normalize({achievements: ["first"], unlockedAt: {first: "x", q10: 5}}).unlockedAt, {})
})

test("1-2 unlocks get their own toast, more are grouped into one", () => {
    const [a, b, c] = S.ACHIEVEMENTS
    same(S.unlockToasts([]), [])
    same(S.unlockToasts([a]), [{title: "🥚 Achievement unlocked: First quack", details: "Quack once"}])
    assert.strictEqual(S.unlockToasts([a, b]).length, 2)
    same(S.unlockToasts([a, b, c]), [{title: "🏅 3 achievements unlocked!", details: "🥚 First quack · 🐣 Chatty duckling · 🎲 The answer"}])
})

test("achievement toast modes: separate always splits, off shows nothing", () => {
    const three = S.ACHIEVEMENTS.slice(0, 3)
    assert.strictEqual(S.unlockToasts(three, "separate").length, 3)
    assert.strictEqual(S.unlockToasts(three, "grouped").length, 1)
    assert.strictEqual(S.unlockToasts(three, undefined).length, 1, "unknown/missing mode behaves like grouped")
    same(S.unlockToasts(three, "off"), [])
})

test("combo achievements use the click context, and need no context otherwise", () => {
    const now = d("2026-03-03")
    const s = S.unlock(S.record(S.normalize(null), "q", now), [S.ACHIEVEMENTS[0]], now)
    const at = combo => ids(S.newlyUnlocked(S.record(s, "q", now), now, {combo: combo}))
    same(at(9), [])
    same(at(10), ["combo10"])
    same(at(25), ["combo10", "combo25"])
    same(at(99), ["combo10", "combo25"])
    same(at(100), ["combo10", "combo25", "combo100"])
    same(ids(S.newlyUnlocked(S.record(s, "q", now), now)), [], "no ctx = no combo")
})

test("history: newest first, rapid same-text quacks merge, capped at 20", () => {
    const at = sec => new Date(2026, 2, 3, 12, 0, sec)
    let s = S.normalize(null)
    s = S.record(s, "Quack!", at(0))
    s = S.record(s, "Quack!", at(1))   // 1 s later, same text: merged
    s = S.record(s, "Quack!", at(3))   // 2 s after the previous one: still merged
    s = S.record(s, "Hi", at(4))       // other text: new entry
    s = S.record(s, "Hi", at(10))      // 6 s later: new entry
    same(s.history.map(h => h.text + "×" + h.count), ["Hi×1", "Hi×1", "Quack!×3"])
    for (let i = 0; i < 30; i++)
        s = S.record(s, "q" + i, at(20 + i * 5))
    assert.strictEqual(s.history.length, 20)
    assert.strictEqual(s.history[0].text, "q29")
})

test("history: old saves load with an empty history, bad entries are dropped", () => {
    same(S.normalize({total: 5}).history, [])
    same(S.normalize({history: [{text: "ok", at: 1}, {text: 3, at: 1}, null]}).history,
         [{text: "ok", at: 1, last: 1, count: 1}])
})

test("feeding counts and unlocks Bread winner at 10", () => {
    const now = d("2026-03-03")
    let s = S.normalize(null)
    for (let i = 0; i < 9; i++)
        s = S.feed(s)
    assert.ok(!ids(S.newlyUnlocked(s, now)).includes("fed10"))
    s = S.feed(s)
    assert.strictEqual(s.fed, 10)
    assert.ok(ids(S.newlyUnlocked(s, now)).includes("fed10"))
    assert.strictEqual(S.normalize({total: 3}).fed, 0, "old saves start at 0")
})

test("achievement ids are unique", () => {
    const all = ids(S.ACHIEVEMENTS)
    assert.strictEqual(new Set(all).size, all.length)
})

