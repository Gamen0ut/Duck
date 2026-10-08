import QtQuick
import qs.Common
import qs.Widgets

// Destructive-action button: the first click arms it (red, "Click again to
// confirm"), a second click within 3 s emits confirmed(). Otherwise it disarms.
DankButton {
    id: root

    property string idleText: ""
    property string idleIcon: "restart_alt"
    property bool armed: false

    signal confirmed

    text: armed ? "Click again to confirm" : idleText
    iconName: armed ? "warning" : idleIcon
    backgroundColor: armed ? Theme.error : Theme.surfaceVariant
    textColor: armed ? Theme.surface : Theme.surfaceText

    onClicked: {
        if (!armed) {
            armed = true
            disarmTimer.restart()
            return
        }
        armed = false
        disarmTimer.stop()
        confirmed()
    }

    Timer {
        id: disarmTimer
        interval: 3000
        onTriggered: root.armed = false
    }
}
