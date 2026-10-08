import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

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

    // ── Reset ─────────────────────────────────────────────

    StyledText {
        width: parent.width
        text: "Reset"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
    }

    ConfirmButton {
        idleText: "Reset to defaults"
        onConfirmed: root.resetToDefaults()
    }
}
