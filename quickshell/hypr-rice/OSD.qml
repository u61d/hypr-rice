import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    required property var theme
    required property var win

    property string currentMode: "volume"
    property int currentValue: 0
    property string currentIcon: "󰕾"

    width: 240
    height: 60
    radius: 30
    color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.85)
    border.width: 1
    border.color: Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.3)

    opacity: win.visible ? 1 : 0
    scale: win.visible ? 1 : 0.8
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text {
            text: root.currentIcon
            color: root.theme.primary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 22
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: Qt.rgba(root.theme.surfaceHigh.r, root.theme.surfaceHigh.g, root.theme.surfaceHigh.b, 0.5)
            clip: true

            Rectangle {
                width: parent.width * (root.currentValue / 100)
                height: parent.height
                radius: 3
                color: root.theme.primary
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            text: root.currentValue + "%"
            color: root.theme.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            font.bold: true
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: win.visible = false
    }

    function showOsd(mode, val) {
        root.currentMode = mode
        root.currentValue = val
        if (mode === "volume") {
            if (val === 0) root.currentIcon = "󰖁"
            else if (val < 30) root.currentIcon = "󰕿"
            else if (val < 70) root.currentIcon = "󰖀"
            else root.currentIcon = "󰕾"
        } else {
            root.currentIcon = "󰃠"
        }
        win.visible = true
        hideTimer.restart()
    }

    Connections {
        target: osdBridge
        function onTickChanged() {
            root.showOsd(osdBridge.mode, osdBridge.value)
        }
    }
}
