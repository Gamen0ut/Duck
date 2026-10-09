// Unit tests for Birds.js. Run: node tests/Birds.test.js
const {assert, load, same, test} = require("./lib")
const B = load("Birds.js")

test("options() feeds the settings dropdown", () => {
    same(B.options()[0], {label: "🦆 Duck", value: "🦆"})
    assert.strictEqual(B.options().length, B.BIRDS.length)
})

test("next() cycles in both directions and wraps around", () => {
    assert.strictEqual(B.next("🦆", 1), "🐤")
    assert.strictEqual(B.next("🦢", 1), "🦆")
    assert.strictEqual(B.next("🦆", -1), "🦢")
    assert.strictEqual(B.next("🐤", -6), "🦆")
})

test("next() treats an unknown bird as the first one", () => {
    assert.strictEqual(B.next("🐧", 1), "🐤")
})

test("random() never returns the current bird", () => {
    for (const r of [0, 0.3, 0.6, 0.99])
        assert.notStrictEqual(B.random("🐥", r), "🐥")
    assert.strictEqual(B.random("🦆", 0), "🐤")
})
