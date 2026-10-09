// Unit tests for Input.js. Run: node tests/Input.test.js
const {assert, load, same, test} = require("./lib")
const I = load("Input.js")

test("one mouse-wheel notch is one step, either direction", () => {
    same(I.wheelSteps(0, 120), {acc: 0, steps: 1})
    same(I.wheelSteps(0, -120), {acc: 0, steps: -1})
    same(I.wheelSteps(0, 360), {acc: 0, steps: 3})
})

test("small touchpad deltas add up to one step", () => {
    let state = {acc: 0, steps: 0}
    let total = 0
    for (let i = 0; i < 12; i++) {
        state = I.wheelSteps(state.acc, 15)
        total += state.steps
    }
    same({total: total, acc: state.acc}, {total: 1, acc: 60})
})

test("changing direction cancels the partial delta", () => {
    same(I.wheelSteps(90, -100), {acc: -10, steps: 0})
})

test("click actions have unique values", () => {
    for (const list of [I.CLICK_ACTIONS, I.LEFT_CLICK_ACTIONS]) {
        const values = list.map(a => a.value)
        assert.strictEqual(new Set(values).size, values.length)
    }
})

test("clicks within 500 ms build a combo, a pause resets it", () => {
    let combo = 0, last = 0
    for (const t of [1000, 1300, 1790]) {
        combo = I.nextCombo(combo, last, t)
        last = t
    }
    assert.strictEqual(combo, 3)
    assert.strictEqual(I.nextCombo(combo, last, last + 500), 4, "500 ms is still in")
    assert.strictEqual(I.nextCombo(combo, last, last + 501), 1, "501 ms starts over")
    assert.strictEqual(I.nextCombo(0, 0, 100), 1, "first click ever")
})

test("combo toasts only at ×10 (warning) and ×25 (error)", () => {
    const levels = []
    for (let c = 1; c <= 30; c++) {
        const t = I.comboToast(c)
        if (t)
            levels.push(c + ":" + t.level)
    }
    same(levels, ["10:warning", "25:error"])
})
