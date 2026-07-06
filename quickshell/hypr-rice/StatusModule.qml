import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    required property var theme
    required property string icon
    required property string command

    property color accent: theme.secondary
    property int interval: 3000
    property string clickCommand: ""
    property string value: "--"

    implicitWidth: Math.max(58, label.implicitWidth + 18)
    Layout.preferredHeight: 28
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : "transparent"
    scale: mouse.containsMouse ? 1.04 : 1

    Behavior on implicitWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.icon + " " + root.value
        color: root.accent
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 13
            bold: true
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickCommand.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.clickCommand.length > 0)
                Quickshell.execDetached(["sh", "-c", root.clickCommand])
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!proc.running) proc.running = true
        }
    }

    Process {
        id: proc
        command: ["sh", "-c", root.command]
        stdout: StdioCollector {
            id: out
            onStreamFinished: {
                const text = out.text.trim()
                root.value = text.length > 0 ? text : "--"
            }
        }
    }
}