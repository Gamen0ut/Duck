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

console.log(`\n${passed} tests passed`)
