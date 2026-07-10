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
    scale: mouse.containsMouse ? 1.08 : 1
    
    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.accent
        font.family: Fonts.icon
        font.pixelSize: 18
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
            if (root.command.length > 0)
                Quickshell.execDetached(["sh", "-c", root.command])
        }
    }
}