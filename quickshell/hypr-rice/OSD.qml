import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    required property var win
    // The OSD window only unmaps once closeAnim finishes, so the shrink/fade
    // out actually plays instead of the surface vanishing the instant the
    // hide timer fires.
    property bool mapped: false

    Binding { target: root.win; property: "visible"; value: root.mapped }

    property string currentMode: "volume"
    property int currentValue: 0
    property string currentIcon: "\ue050" // volume_up

    width: 240
    height: 60
    radius: 30
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.85)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

    opacity: 0
    scale: 0.8
    transformOrigin: Item.Bottom

    ParallelAnimation {
        id: openAnim
        running: false
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "scale"; to: 1; duration: 320; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
    }

    ParallelAnimation {
        id: closeAnim
        running: false
        onFinished: root.mapped = false
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 160; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "scale"; to: 0.82; duration: 180; easing.type: Easing.InCubic }
    }

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
        onTriggered: {
            openAnim.stop()
            closeAnim.restart()
        }
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
        closeAnim.stop()
        root.mapped = true
        openAnim.restart()
        hideTimer.restart()
    }

    Connections {
        target: osdBridge
        function onTickChanged() {
            root.showOsd(osdBridge.mode, osdBridge.value)
        }
    }
}
