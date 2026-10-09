.pragma library

// Pure mouse-input logic for the pill (testable with node).

var WHEEL_NOTCH = 120 // angleDelta of one mouse-wheel notch

// Touchpads send many small deltas instead of one 120 notch, so deltas are
// accumulated and one step is taken per full notch. Returns the new
// accumulator and the number of steps (positive = wheel up / away).
function wheelSteps(acc, delta) {
    const total = acc + delta
    const steps = Math.trunc(total / WHEEL_NOTCH)
    return {acc: total - steps * WHEEL_NOTCH, steps: steps}
}
