.pragma library

// The birds you can pick: the single list used by the settings dropdown, the
// scroll wheel and the "random bird" action.
var BIRDS = [
    {emoji: "🦆", name: "Duck"},
    {emoji: "🐤", name: "Chick"},
    {emoji: "🐥", name: "Front chick"},
    {emoji: "🐣", name: "Hatching"},
    {emoji: "🦢", name: "Swan"}
]

// Options for a SelectionSetting.
function options() {
    return BIRDS.map(b => ({label: b.emoji + " " + b.name, value: b.emoji}))
}

// The bird `step` places after `emoji` (negative = before), wrapping around.
// An unknown emoji counts as the first bird.
function next(emoji, step) {
    const i = Math.max(0, BIRDS.findIndex(b => b.emoji === emoji))
    const n = BIRDS.length
    return BIRDS[((i + step) % n + n) % n].emoji
}

// A random bird other than `emoji`. `rand` (0 <= x < 1) defaults to
// Math.random; tests pass their own.
function random(emoji, rand) {
    const others = BIRDS.filter(b => b.emoji !== emoji)
    const r = rand === undefined ? Math.random() : rand
    return others[Math.floor(r * others.length)].emoji
}
