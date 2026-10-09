// Unit tests for DuckStats.js. Run: node tests/DuckStats.test.js
// DuckStats.js is a QML JS library, so strip `.pragma library` and evaluate
// it in a sandbox to get its functions.
const assert = require("assert")
const fs = require("fs")
const path = require("path")
const vm = require("vm")

const source = fs.readFileSync(path.join(__dirname, "..", "DuckStats.js"), "utf8")
    .replace(/^\.pragma library$/m, "")
const S = {}
vm.runInNewContext(source + "\nObject.assign(exports, {emptyStats, normalize, dayKey, streak, summary, record, newlyUnlocked, unlock, ACHIEVEMENTS})", {exports: S})

const d = s => new Date(s + "T12:00:00")
const ids = list => list.map(a => a.id)
// Objects from the sandbox have their own Object prototype, so compare them
// as plain JSON values.
const plain = x => JSON.parse(JSON.stringify(x))
const same = (actual, expected) => assert.deepStrictEqual(plain(actual), plain(expected))

let passed = 0
function test(name, fn) {
    fn()
    passed++
    console.log("ok -", name)
}

test("dayKey uses local time and zero-pads", () => {
    assert.strictEqual(S.dayKey(new Date(2026, 0, 5)), "2026-01-05")
})

test("record counts total, today and last quack", () => {
    let s = S.normalize(null)
    s = S.record(s, "Quack!", d("2026-10-07"))
    s = S.record(s, "Quack!", d("2026-10-08"))
    s = S.record(s, "Hi", d("2026-10-09"))
    s = S.record(s, "Hi2", d("2026-10-09"))
    same(S.summary(s, d("2026-10-09")), {total: 4, today: 2, streak: 3, lastQuack: "Hi2"})
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
    s = S.unlock(s, S.newlyUnlocked(s, d("2026-10-09")))
    same(S.newlyUnlocked(s, d("2026-10-09")), [])
    for (let i = 0; i < 24; i++)
        s = S.record(s, "q", d("2026-10-09"))
    same(ids(S.newlyUnlocked(s, d("2026-10-09"))), ["q10", "day25"])
    s = S.unlock(s, S.newlyUnlocked(s, d("2026-10-09")))
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
            stats = S.unlock(stats, S.newlyUnlocked(stats, now))
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

test("achievement ids are unique", () => {
    const all = ids(S.ACHIEVEMENTS)
    assert.strictEqual(new Set(all).size, all.length)
})

console.log(`\n${passed} tests passed`)
