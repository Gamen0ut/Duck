import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string quackText: pluginData.quackText || "Quack!"
    property bool showToast: pluginData.showToast !== undefined ? pluginData.showToast : true
    property bool quacking: false

    function quack() {
        quacking = true
        resetTimer.restart()
        if (showToast)
            ToastService.showInfo("🦆 " + quackText)
    }

    Timer {
        id: resetTimer
        interval: 1500
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
                    text: "🦆"
                    font.pixelSize: Theme.fontSizeLarge
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    visible: root.quacking
                    text: root.quackText
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: Theme.primary
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
                    text: "🦆"
                    font.pixelSize: Theme.fontSizeLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    visible: root.quacking
                    text: "Q!"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.primary
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
