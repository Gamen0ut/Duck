import QtQuick
import qs.Common
import qs.Widgets
import "DuckStats.js" as Stats

// Every achievement: unlocked ones with their icon and unlock date, locked
// ones faded, secret ones as "???". Used by the settings page and the popout.
Column {
    id: root

    property var stats: Stats.emptyStats()

    width: parent ? parent.width : implicitWidth
    spacing: Theme.spacingXS

    Repeater {
        model: Stats.ACHIEVEMENTS

        Row {
            id: row

            required property var modelData
            readonly property bool unlocked: root.stats.achievements.indexOf(modelData.id) !== -1
            readonly property bool secret: modelData.hidden === true && !unlocked

            width: root.width
            spacing: Theme.spacingS
            opacity: unlocked ? 1 : 0.4

            StyledText {
                id: icon
                text: row.unlocked ? row.modelData.icon : "🔒"
                font.pixelSize: Theme.fontSizeMedium
            }
            StyledText {
                width: row.width - icon.width - row.spacing
                text: {
                    if (row.secret)
                        return "??? · Secret achievement"
                    const at = root.stats.unlockedAt[row.modelData.id]
                    return row.modelData.name + " · " + row.modelData.description
                        + (at ? " · " + Qt.formatDate(new Date(at), "d MMM yyyy") : "")
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                wrapMode: Text.WordWrap
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
