import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    required property string icon
    required property string command

    property color accent: Theme.secondary
    property int interval: 3000
    property string clickCommand: ""
    property string value: "--"
    property bool thresholdColors: false

    onValueChanged: {
        if (!thresholdColors) return
        const n = parseInt(value)
        if (isNaN(n)) return
        if (n >= 90) root.accent = Theme.red
        else if (n >= 75) root.accent = Theme.yellow
        else root.accent = Theme.green
    }

    implicitWidth: Math.max(58, row.implicitWidth + 18)
    Layout.preferredHeight: 28
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : "transparent"
    scale: mouse.containsMouse ? 1.04 : 1

    Behavior on implicitWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: root.accent
            font.family: Fonts.icon
            font.pixelSize: 16
        }

        Text {
            text: root.value
            color: root.accent
            font.family: Fonts.sans
            font.pixelSize: 13
            font.weight: Font.Medium
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