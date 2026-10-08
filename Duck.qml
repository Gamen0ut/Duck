import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

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

    property bool quacking: false
    property string currentQuack: quackText

    function pickQuack() {
        if (randomQuack && quackPhrases.length > 0)
            return quackPhrases[Math.floor(Math.random() * quackPhrases.length)]
        return quackText
    }

    function quack() {
        currentQuack = pickQuack()
        quacking = true
        resetTimer.restart()
        if (showToast)
            ToastService.showInfo(duckEmoji + " " + currentQuack)
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
                cursorShape: Qt.PointingHandCursor
                onClicked: root.quack()
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
                cursorShape: Qt.PointingHandCursor
                onClicked: root.quack()
            }
        }
    }
}
