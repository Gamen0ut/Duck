import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets
import "DuckStats.js" as Stats

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
        options: [
            {label: "🦆 Duck", value: "🦆"},
            {label: "🐤 Chick", value: "🐤"},
            {label: "🐥 Front chick", value: "🐥"},
            {label: "🐣 Hatching", value: "🐣"},
            {label: "🦢 Swan", value: "🦢"}
        ]
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

    Column {
        width: parent.width
        spacing: Theme.spacingXS

        Repeater {
            model: Stats.ACHIEVEMENTS

            Row {
                required property var modelData
                readonly property bool unlocked: root.stats.achievements.indexOf(modelData.id) !== -1

                spacing: Theme.spacingS
                opacity: unlocked ? 1 : 0.4

                StyledText {
                    text: parent.unlocked ? parent.modelData.icon : "🔒"
                    font.pixelSize: Theme.fontSizeMedium
                }
                StyledText {
                    text: parent.modelData.name + " · " + parent.modelData.description
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
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
