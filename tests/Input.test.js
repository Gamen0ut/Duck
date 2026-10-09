// Unit tests for Input.js. Run: node tests/Input.test.js
const {load, same, test} = require("./lib")
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
