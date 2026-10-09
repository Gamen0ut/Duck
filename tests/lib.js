// Shared helpers for the unit tests (plain node, no dependencies).
const assert = require("assert")
const fs = require("fs")
const path = require("path")
const vm = require("vm")

// Loads a QML JS library (e.g. "DuckStats.js") from the plugin folder.
// `.pragma library` is QML-only, so it's stripped; the code then runs in a
// sandbox whose global object exposes every top-level `function` and `var`.
function load(file) {
    const source = fs.readFileSync(path.join(__dirname, "..", file), "utf8")
        .replace(/^\.pragma library$/m, "")
    const sandbox = {}
    vm.runInNewContext(source, sandbox, {filename: file})
    return sandbox
}

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
process.on("exit", code => {
    if (code === 0)
        console.log(`\n${passed} tests passed`)
})

module.exports = {assert, load, plain, same, test}
