import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "duck"

    StyledText {
        width: parent.width
        text: "🦆 Duck"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "quackText"
        label: "Quack text"
        description: "What the duck says when clicked"
        placeholder: "Quack!"
        defaultValue: "Quack!"
    }

    ToggleSetting {
        settingKey: "showToast"
        label: "Show toast"
        description: "Also pop a notification when the duck quacks"
        defaultValue: true
    }
}
