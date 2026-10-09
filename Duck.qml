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
    property string leftClickAction: pluginData.leftClickAction || "quack"
    property string rightClickAction: pluginData.rightClickAction || "popout"
    property string middleClickAction: pluginData.middleClickAction || "randomBird"

    property bool quacking: false
    property string currentQuack: quackText
    property Item hoveredPill: null // for refreshing the tooltip after a click

    // Clicks go through DMS's own pill MouseArea (whole pill incl. padding,
    // with the ripple effect) instead of a MouseArea of ours.
    pillRightClickAction: () => runAction(rightClickAction)

    // Left-click: with a pillClickAction DMS runs it; without one, DMS opens
    // our popout itself. Assigned imperatively (not a binding) because
    // openPopout() temporarily clears it.
    readonly property var quackClick: () => quack()

    function applyLeftClick() {
        pillClickAction = leftClickAction === "popout" ? null : quackClick
    }

    onLeftClickActionChanged: applyLeftClick()

    // DMS's triggerPopout() runs pillClickAction instead of opening the popout
    // when one is set ("pillClickAction overrides popout"), and there's no
    // other API to open a plugin's own popout. So clear it for this one call.
    function openPopout() {
        pillClickAction = null
        triggerPopout()
        applyLeftClick()
    }

    // Actions for right-/middle-click (see Input.CLICK_ACTIONS).
    function runAction(action) {
        switch (action) {
        case "silent":
            quack(true)
            break
        case "randomBird":
            setBird(Birds.random(duckEmoji))
            break
        case "popout":
            openPopout()
            break
        case "stats":
            ToastService.showInfo(tooltipText())
            break
        }
    }

    function pickQuack() {
        if (randomQuack && quackPhrases.length > 0)
            return quackPhrases[Math.floor(Math.random() * quackPhrases.length)]
        return quackText
    }

    // ── Combo ─────────────────────────────────────────────

    property int combo: 0
    property real lastClickMs: 0
    readonly property string comboSuffix: combo > 1 ? " ×" + combo : ""

    function showComboToast() {
        const t = Input.comboToast(combo)
        if (!t)
            return
        if (t.level === "error")
            ToastService.showError(t.text)
        else
            ToastService.showWarning(t.text)
    }

    function quack(silent) {
        const now = Date.now()
        combo = Input.nextCombo(combo, lastClickMs, now)
        lastClickMs = now
        if (combo === 1)
            currentQuack = pickQuack() // keep the same text during a combo
        quacking = true
        resetTimer.restart()
        recordQuack()
        if (showToast && !silent) {
            if (combo === 1)
                ToastService.showInfo(duckEmoji + " " + currentQuack)
            showComboToast()
        }
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
        const unlocked = Stats.newlyUnlocked(stats, now, {combo: combo})
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

    Component.onCompleted: {
        applyLeftClick()
        loadStats()
    }
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
                    text: root.currentQuack + root.comboSuffix
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: root.quackColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                // Only the middle button: left/right fall through to DMS's pill.
                acceptedButtons: Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runAction(root.middleClickAction)
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
                    text: root.combo > 1 ? "×" + root.combo : "Q!"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: root.quackColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                // Only the middle button: left/right fall through to DMS's pill.
                acceptedButtons: Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runAction(root.middleClickAction)
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

    // ── Popout ────────────────────────────────────────────

    popoutWidth: 360

    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: root.duckEmoji + " Duck"
            showCloseButton: true

            readonly property var summary: Stats.summary(root.stats, new Date())

            // Tabs are identified by id, so adding one doesn't shift the others.
            readonly property var tabs: [
                {id: "history", label: "History"},
                {id: "achievements", label: "Achievements"}
            ]
            property string tab: "history"

            function timeLabel(ms) {
                const d = new Date(ms)
                const sameDay = d.toDateString() === new Date().toDateString()
                return Qt.formatDateTime(d, sameDay ? "HH:mm" : "d MMM HH:mm")
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM
                topPadding: Theme.spacingS
                bottomPadding: Theme.spacingM

                // Big duck: click it to quack (same as the pill, combos too)
                Item {
                    width: parent.width
                    height: bigDuck.implicitHeight + quackLine.implicitHeight

                    StyledText {
                        id: bigDuck
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.duckEmoji
                        font.pixelSize: 72
                    }
                    StyledText {
                        id: quackLine
                        anchors.top: bigDuck.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.currentQuack + root.comboSuffix
                        opacity: root.quacking ? 1 : 0
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Bold
                        color: root.quackColor
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.quack()
                    }
                }

                // Stats
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingL

                    Repeater {
                        model: [
                            {value: popout.summary.total, label: "quacks"},
                            {value: popout.summary.today, label: "today"},
                            {value: "🔥 " + popout.summary.streak, label: "day streak"},
                            {value: "🏅 " + root.stats.achievements.length + "/" + Stats.ACHIEVEMENTS.length, label: "achievements"}
                        ]

                        Column {
                            required property var modelData
                            spacing: 2

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: parent.modelData.value
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Bold
                                color: Theme.surfaceText
                            }
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: parent.modelData.label
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }
                }

                DankButtonGroup {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: popout.tabs.length > 1
                    buttonHeight: 32
                    textSize: Theme.fontSizeSmall
                    model: popout.tabs.map(t => t.label)
                    currentIndex: popout.tabs.findIndex(t => t.id === popout.tab)
                    selectionMode: "single"
                    onSelectionChanged: (index, selected) => {
                        if (selected)
                            popout.tab = popout.tabs[index].id
                    }
                }

                // Tab content: fixed height, each tab scrolls on its own
                Item {
                    width: parent.width
                    height: 260

                    DankListView {
                        anchors.fill: parent
                        visible: popout.tab === "history"
                        clip: true
                        spacing: Theme.spacingXS
                        model: root.stats.history

                        delegate: Row {
                            required property var modelData
                            width: ListView.view.width
                            spacing: Theme.spacingS

                            StyledText {
                                width: 90
                                text: popout.timeLabel(parent.modelData.at)
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                            StyledText {
                                width: parent.width - 90 - parent.spacing
                                text: parent.modelData.text + (parent.modelData.count > 1 ? "  ×" + parent.modelData.count : "")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                elide: Text.ElideRight
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            visible: root.stats.history.length === 0
                            text: "No quacks yet. Click the duck!"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }

                    DankFlickable {
                        anchors.fill: parent
                        visible: popout.tab === "achievements"
                        clip: true
                        contentWidth: width
                        contentHeight: achievementList.implicitHeight

                        AchievementList {
                            id: achievementList
                            width: parent.width
                            stats: root.stats
                        }
                    }
                }
            }
        }
    }
}
