import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    required property string icon
    property color accent: Theme.secondary
    property string command: ""
    signal clicked()

    Layout.preferredWidth: 30
    Layout.preferredHeight: 28
    radius: 11

    color: mouse.containsMouse ? Qt.rgba(accent.r, accent.g, accent.b, 0.2) : "transparent"
    scale: mouse.pressed ? 0.88 : (mouse.containsMouse ? 1.08 : 1)

    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: mouse.pressed ? 90 : 160; easing.type: mouse.pressed ? Easing.OutCubic : Easing.OutBack; easing.overshoot: 2.2 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.icon
        color: root.accent
        font.family: Fonts.icon
        font.pixelSize: 18
        scale: 1

        SequentialAnimation {
            id: popAnim
            NumberAnimation { target: label; property: "scale"; to: 1.35; duration: 90; easing.type: Easing.OutCubic }
            NumberAnimation { target: label; property: "scale"; to: 1; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 3 }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            popAnim.restart()
            root.clicked()
            if (root.command.length > 0)
                Quickshell.execDetached(["sh", "-c", root.command])
        }
    }
}