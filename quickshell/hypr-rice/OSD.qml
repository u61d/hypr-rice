import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    required property var win

    property string currentMode: "volume"
    property int currentValue: 0
    property string currentIcon: "\ue050" // volume_up

    width: 240
    height: 60
    radius: 30
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.85)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

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
            color: Theme.primary
            font.family: Fonts.icon
            font.pixelSize: 20
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)
            clip: true

            Rectangle {
                width: parent.width * (root.currentValue / 100)
                height: parent.height
                radius: 3
                color: Theme.primary
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            text: root.currentValue + "%"
            color: Theme.text
            font.family: Fonts.sans
            font.pixelSize: 14
            font.weight: Font.DemiBold
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
            if (val === 0) root.currentIcon = "\ue04f" // volume_off
            else if (val < 30) root.currentIcon = "\ue04d" // volume_down
            else if (val < 70) root.currentIcon = "\ue050" // volume_up
            else root.currentIcon = "\ue050" // volume_up
        } else {
            root.currentIcon = "\ue3ab" // brightness_6
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
