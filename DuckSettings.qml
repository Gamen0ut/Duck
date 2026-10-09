import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets
import "DuckStats.js" as Stats
import "Birds.js" as Birds
import "Input.js" as Input

PluginSettings {
    id: root
    pluginId: "duck"

    // Writes every setting's defaultValue back to storage. Saving emits
    // pluginDataChanged, which makes PluginSettings reload each control.
    function resetToDefaults() {
        for (let i = 0; i < content.length; i++) {
            const child = content[i]
            if (child.settingKey === undefined || child.defaultValue === undefined)
                continue
            let value = child.defaultValue
            if (typeof value === "object" && value !== null && !Array.isArray(value))
                value = value.toString() // ColorSetting stores colors as "#rrggbb"
            saveValue(child.settingKey, value)
        }
        ToastService.showInfo("🦆 Duck settings reset to defaults")
    }

    // Stats live in the plugin state (see DuckStats.js), not in settings.
    property var stats: Stats.emptyStats()
    readonly property var statsSummary: Stats.summary(stats, new Date())

    function loadStats() {
        if (pluginService)
            stats = Stats.normalize(pluginService.loadPluginState(pluginId, "stats", null))
    }

    function resetStats() {
        if (!pluginService)
            return
        pluginService.clearPluginState(pluginId)
        ToastService.showInfo("🦆 Quack stats reset")
    }

    onPluginServiceChanged: loadStats()

    Connections {
        target: root.pluginService
        enabled: root.pluginService !== null
        function onPluginStateChanged(changedId) {
            if (changedId === root.pluginId)
                root.loadStats()
        }
    }

    StyledText {
        width: parent.width
        text: "🦆 Duck"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "A duck in your bar. Click it, it quacks."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    // ── Look ──────────────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Look"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    SelectionSetting {
        settingKey: "duckEmoji"
        label: "Duck"
        description: "Which bird lives in your bar"
        options: Birds.options()
        defaultValue: "🦆"
    }

    ToggleSetting {
        settingKey: "hideEmojiWhenQuacking"
        label: "Hide duck while quacking"
        description: "Only show the quack text during a quack"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "useCustomColor"
        label: "Custom quack color"
        description: "Use the color below instead of the theme accent"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "showCounter"
        label: "Show quack counter"
        description: "Show the total number of quacks next to the duck"
        defaultValue: false
    }

    ColorSetting {
        settingKey: "quackColor"
        label: "Quack color"
        description: "Color of the quack text"
        defaultValue: Theme.primary
    }

    // ── Quack ─────────────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Quack"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    StringSetting {
        settingKey: "quackText"
        label: "Quack text"
        description: "What the duck says when clicked"
        placeholder: "Quack!"
        defaultValue: "Quack!"
    }

    SliderSetting {
        settingKey: "quackDuration"
        label: "Quack duration"
        description: "How long the quack stays visible"
        defaultValue: 1500
        minimum: 500
        maximum: 5000
        unit: "ms"
        leftIcon: "timer"
    }

    ToggleSetting {
        settingKey: "randomQuack"
        label: "Random quacks"
        description: "Pick a random phrase from the list below instead of the quack text"
        defaultValue: false
    }

    ListSettingWithInput {
        settingKey: "quackPhrases"
        label: "Quack phrases"
        description: "Phrases used when random quacks are on"
        defaultValue: []
        fields: [
            {id: "text", label: "Phrase", placeholder: "Quack quack!", width: 250, required: true}
        ]
    }

    // ── Mouse ─────────────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Mouse"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    SelectionSetting {
        settingKey: "leftClickAction"
        label: "Left-click"
        description: "What a left-click on the duck does"
        options: Input.LEFT_CLICK_ACTIONS
        defaultValue: "quack"
    }

    SelectionSetting {
        settingKey: "rightClickAction"
        label: "Right-click"
        description: "What a right-click on the duck does"
        options: Input.CLICK_ACTIONS
        defaultValue: "popout"
    }

    SelectionSetting {
        settingKey: "middleClickAction"
        label: "Middle-click"
        description: "What a middle-click on the duck does"
        options: Input.CLICK_ACTIONS
        defaultValue: "randomBird"
    }

    ToggleSetting {
        settingKey: "scrollChangesBird"
        label: "Scroll to change bird"
        description: "Use the mouse wheel over the duck to switch birds"
        defaultValue: true
    }

    // ── Notifications ─────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Notifications"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    ToggleSetting {
        settingKey: "showToast"
        label: "Show toast"
        description: "Also pop a notification when the duck quacks"
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "achievementToasts"
        label: "Achievement toasts"
        description: "How unlocked achievements are announced"
        options: [
            {label: "Grouped when more than 2", value: "grouped"},
            {label: "One toast per achievement", value: "separate"},
            {label: "Off", value: "off"}
        ]
        defaultValue: "grouped"
    }

    // ── Stats ─────────────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Stats"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    StyledText {
        width: parent.width
        text: root.statsSummary.total + " quacks · " + root.statsSummary.today + " today · 🔥 "
              + root.statsSummary.streak + "-day streak"
              + (root.statsSummary.lastQuack ? " · last: \u201c" + root.statsSummary.lastQuack + "\u201d" : "")
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.surfaceText
        wrapMode: Text.WordWrap
    }

    StyledText {
        width: parent.width
        text: "Achievements " + root.stats.achievements.length + "/" + Stats.ACHIEVEMENTS.length
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
        color: Theme.surfaceVariantText
    }

    AchievementList {
        stats: root.stats
    }

    ConfirmButton {
        idleText: "Reset stats"
        idleIcon: "delete_sweep"
        onConfirmed: root.resetStats()
    }

    // ── Reset ─────────────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Reset"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    StyledText {
        width: parent.width
        text: "Restores every setting above. Quack stats are kept."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    ConfirmButton {
        idleText: "Reset to defaults"
        onConfirmed: root.resetToDefaults()
    }
}
