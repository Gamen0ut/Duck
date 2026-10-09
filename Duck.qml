import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "DuckStats.js" as Stats
import "Birds.js" as Birds
import "Input.js" as Input

PluginComponent {
    id: root

    property string quackText: pluginData.quackText || "Quack!"
    property bool showToast: pluginData.showToast ?? true
    property string duckEmoji: pluginData.duckEmoji || "🦆"
    property bool hideEmojiWhenQuacking: pluginData.hideEmojiWhenQuacking ?? false
    property int quackDuration: pluginData.quackDuration || 1500
    property color quackColor: (pluginData.useCustomColor && pluginData.quackColor) ? pluginData.quackColor : Theme.primary
    property bool randomQuack: pluginData.randomQuack ?? false
    property var quackPhrases: (pluginData.quackPhrases || []).map(p => p.text).filter(t => t)
    property bool showCounter: pluginData.showCounter ?? false
    property string achievementToasts: pluginData.achievementToasts || "grouped"
    property bool scrollChangesBird: pluginData.scrollChangesBird ?? true

    property bool quacking: false
    property string currentQuack: quackText
    property Item hoveredPill: null // for refreshing the tooltip after a click

    // Clicks go through DMS's own pill MouseArea (whole pill incl. padding,
    // with the ripple effect) instead of a MouseArea of ours.
    pillClickAction: () => quack()

    function pickQuack() {
        if (randomQuack && quackPhrases.length > 0)
            return quackPhrases[Math.floor(Math.random() * quackPhrases.length)]
        return quackText
    }

    function quack() {
        currentQuack = pickQuack()
        quacking = true
        resetTimer.restart()
        recordQuack()
        if (showToast)
            ToastService.showInfo(duckEmoji + " " + currentQuack)
        if (hoveredPill)
            showTooltip(hoveredPill) // refresh the numbers
    }

    // The widget writes its own setting: savePluginData() notifies every
    // Duck instance and the settings page, exactly like the dropdown does.
    function setBird(emoji) {
        if (pluginService && emoji !== duckEmoji)
            pluginService.savePluginData(stateId, "duckEmoji", emoji)
    }

    // ── Scroll wheel ──────────────────────────────────────

    property real wheelAcc: 0

    function handleWheel(delta) {
        const r = Input.wheelSteps(wheelAcc, delta)
        wheelAcc = r.acc
        if (r.steps !== 0)
            setBird(Birds.next(duckEmoji, -r.steps)) // wheel down = next bird
    }

    // ── Stats (plugin state, not settings) ────────────────

    readonly property string stateId: pluginId || "duck"
    property var stats: Stats.emptyStats()

    function loadStats() {
        if (!pluginService)
            return
        stats = Stats.normalize(pluginService.loadPluginState(stateId, "stats", null))
        if (!quacking && stats.lastQuack)
            currentQuack = stats.lastQuack
    }

    function recordQuack() {
        const now = new Date()
        stats = Stats.record(stats, currentQuack, now)
        const unlocked = Stats.newlyUnlocked(stats, now)
        if (unlocked.length > 0) {
            stats = Stats.unlock(stats, unlocked, now)
            for (const t of Stats.unlockToasts(unlocked, achievementToasts))
                ToastService.showInfo(t.title, t.details)
        }
        if (pluginService)
            pluginService.savePluginState(stateId, "stats", stats)
    }

    function tooltipText() {
        const s = Stats.summary(stats, new Date())
        let text = duckEmoji + " " + s.total + (s.total === 1 ? " quack" : " quacks") + " · " + s.today + " today"
        if (s.streak > 1)
            text += " · 🔥 " + s.streak + "-day streak"
        text += " · 🏅 " + stats.achievements.length + "/" + Stats.ACHIEVEMENTS.length
        return text
    }

    Component.onCompleted: { console.warn("PROBE-V3 jsMarker=" + (typeof Stats.probeMarker)); loadStats() }
    onPluginServiceChanged: loadStats()

    // Another Duck instance (other bar/monitor) or the settings page changed
    // the stats: reload so every instance shows the same numbers.
    Connections {
        target: root.pluginService
        enabled: root.pluginService !== null
        function onPluginStateChanged(changedId) {
            if (changedId === root.stateId)
                root.loadStats()
        }
    }

    // ── Tooltip ───────────────────────────────────────────
    // DankTooltip is its own layer window positioned in screen coordinates,
    // so it isn't clipped by the bar (same approach as DMS's Vpn widget).

    Loader {
        id: tooltipLoader
        active: false
        sourceComponent: DankTooltip {}
    }

    function showTooltip(item) {
        if (!parentScreen)
            return
        tooltipLoader.active = true
        if (!tooltipLoader.item)
            return
        const edge = axis?.edge || "top"
        const screen = parentScreen
        if (edge === "left" || edge === "right") {
            const pos = item.mapToItem(null, item.width / 2, item.height / 2)
            const x = edge === "left"
                ? barThickness + barSpacing + Theme.spacingXS
                : screen.width - barThickness - barSpacing - Theme.spacingXS
            tooltipLoader.item.show(tooltipText(), x, pos.y, screen, edge === "left", edge === "right")
        } else {
            const pos = item.mapToItem(null, item.width / 2, 0)
            const y = edge === "bottom"
                ? screen.height - barThickness - barSpacing - Theme.spacingXS - (Theme.fontSizeSmall * 1.5 + Theme.spacingS * 2)
                : barThickness + barSpacing + Theme.spacingXS
            tooltipLoader.item.show(tooltipText(), pos.x, y, screen, false, false)
        }
    }

    function hideTooltip() {
        if (tooltipLoader.item)
            tooltipLoader.item.hide()
        tooltipLoader.active = false
    }

    Timer {
        id: resetTimer
        interval: root.quackDuration
        onTriggered: root.quacking = false
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: hRow.implicitWidth
            implicitHeight: hRow.implicitHeight

            Row {
                id: hRow
                spacing: Theme.spacingS

                StyledText {
                    visible: !(root.quacking && root.hideEmojiWhenQuacking)
                    text: root.duckEmoji
                    font.pixelSize: Theme.fontSizeLarge
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    visible: root.showCounter && !root.quacking
                    text: root.stats.total
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    visible: root.quacking
                    text: root.currentQuack
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: root.quackColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton // clicks fall through to DMS's pill
                cursorShape: Qt.PointingHandCursor
                onWheel: wheel => {
                    wheel.accepted = root.scrollChangesBird
                    if (root.scrollChangesBird)
                        root.handleWheel(wheel.angleDelta.y || wheel.angleDelta.x)
                }
                onEntered: {
                    root.hoveredPill = parent
                    root.showTooltip(parent)
                }
                onExited: {
                    root.hoveredPill = null
                    root.hideTooltip()
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: vCol.implicitWidth
            implicitHeight: vCol.implicitHeight

            Column {
                id: vCol
                spacing: Theme.spacingXS

                StyledText {
                    visible: !(root.quacking && root.hideEmojiWhenQuacking)
                    text: root.duckEmoji
                    font.pixelSize: Theme.fontSizeLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    visible: root.showCounter && !root.quacking
                    text: root.stats.total
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    visible: root.quacking
                    text: "Q!"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: root.quackColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton // clicks fall through to DMS's pill
                cursorShape: Qt.PointingHandCursor
                onWheel: wheel => {
                    wheel.accepted = root.scrollChangesBird
                    if (root.scrollChangesBird)
                        root.handleWheel(wheel.angleDelta.y || wheel.angleDelta.x)
                }
                onEntered: {
                    root.hoveredPill = parent
                    root.showTooltip(parent)
                }
                onExited: {
                    root.hoveredPill = null
                    root.hideTooltip()
                }
            }
        }
    }
}
