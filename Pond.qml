import QtQuick
import qs.Common
import qs.Widgets
import "Birds.js" as Birds

// A pond with `count` birds swimming back and forth. The first one is the
// current bird; the others cycle through the bird list. Animations only run
// while `active`, so a hidden pond costs nothing.
Rectangle {
    id: pond

    property int count: 1
    property string mainBird: "🦆"
    property bool active: visible
    signal birdClicked

    // 6 lanes keep up to 12 birds apart vertically (a bird is ~36 px tall,
    // the popout's pond 260 px); two birds share a lane at most, starting
    // from opposite sides.
    readonly property int lanes: 6

    radius: Theme.cornerRadius
    color: Theme.withAlpha(Theme.primary, 0.12)
    clip: true

    Repeater {
        model: pond.count

        Item {
            id: swimmer

            required property int index
            readonly property int laneIndex: index % pond.lanes
            readonly property real lane: (laneIndex + 0.5) / pond.lanes // 0..1, top to bottom
            readonly property int swimMs: 4000 + (index * 1373) % 5000 // varied, but stable
            // neighbouring lanes alternate, and a lane's second bird starts
            // on the other side than its first
            readonly property bool startsRight: (laneIndex + Math.floor(index / pond.lanes)) % 2 === 1
            readonly property real rightEdge: pond.width - width
            property bool facingRight: !startsRight

            width: bird.implicitWidth
            height: bird.implicitHeight
            y: lane * (pond.height - height)
            x: startsRight ? rightEdge : 0

            StyledText {
                id: bird
                text: swimmer.index === 0 ? pond.mainBird : Birds.next(pond.mainBird, swimmer.index)
                font.pixelSize: 28
                // emojis face left: mirror them while swimming right
                transform: Scale {
                    origin.x: bird.width / 2
                    xScale: swimmer.facingRight ? -1 : 1
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pond.birdClicked()
            }

            // Swim across, turn around, swim back, turn around. Both legs have
            // fixed targets: a looping animation reads them when it starts.
            SequentialAnimation {
                running: pond.active && pond.width > 0
                loops: Animation.Infinite

                NumberAnimation {
                    target: swimmer
                    property: "x"
                    to: swimmer.startsRight ? 0 : swimmer.rightEdge
                    duration: swimmer.swimMs
                    easing.type: Easing.InOutSine
                }
                ScriptAction {
                    script: swimmer.facingRight = !swimmer.facingRight
                }
                NumberAnimation {
                    target: swimmer
                    property: "x"
                    to: swimmer.startsRight ? swimmer.rightEdge : 0
                    duration: swimmer.swimMs
                    easing.type: Easing.InOutSine
                }
                ScriptAction {
                    script: swimmer.facingRight = !swimmer.facingRight
                }
            }

            // Gentle bobbing on the water.
            SequentialAnimation on y {
                running: pond.active && pond.height > 0
                loops: Animation.Infinite
                NumberAnimation {
                    to: swimmer.lane * (pond.height - swimmer.height) - 3
                    duration: 900 + swimmer.index * 70
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: swimmer.lane * (pond.height - swimmer.height) + 3
                    duration: 900 + swimmer.index * 70
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
