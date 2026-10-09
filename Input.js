.pragma library

// Pure mouse-input logic for the pill (testable with node).

var WHEEL_NOTCH = 120 // angleDelta of one mouse-wheel notch

// Actions a right- or middle-click can run (SelectionSetting options).
var CLICK_ACTIONS = [
    {label: "Silent quack (no toast)", value: "silent"},
    {label: "Random bird", value: "randomBird"},
    {label: "Show stats", value: "stats"},
    {label: "Nothing", value: "none"}
]

// Touchpads send many small deltas instead of one 120 notch, so deltas are
// accumulated and one step is taken per full notch. Returns the new
// accumulator and the number of steps (positive = wheel up / away).
function wheelSteps(acc, delta) {
    const total = acc + delta
    const steps = Math.trunc(total / WHEEL_NOTCH)
    return {acc: total - steps * WHEEL_NOTCH, steps: steps}
}

// ── Combos ───────────────────────────────────────────────
// Rapid clicks build a combo instead of using a classic double-click, which
// would delay every single click while waiting for a possible second one.

var COMBO_WINDOW_MS = 500 // max time between two clicks of the same combo

// Combo count after a click at `now` (ms), given the previous click time.
function nextCombo(combo, lastClickMs, now) {
    return combo > 0 && now - lastClickMs <= COMBO_WINDOW_MS ? combo + 1 : 1
}

// Toast for combo milestones, or null. `level` matches ToastService:
// "warning" -> showWarning, "error" -> showError.
function comboToast(combo) {
    if (combo === 10)
        return {level: "warning", text: "😵 Quack ×10! The duck is getting dizzy…"}
    if (combo === 25)
        return {level: "error", text: "💥 Quack ×25! The duck needs a break!"}
    return null
}
