import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    required property var theme
    property bool expanded: false
    property int brightness: 0

    implicitWidth: expanded ? 240 : 0
    implicitHeight: expanded ? 80 : 0
    radius: 16
    clip: true
    color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.92)
    border.width: 1
    border.color: Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.3)

    opacity: expanded ? 1 : 0
    visible: opacity > 0

    Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    function updateBrightness() {
        let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "brightnessctl -m | awk -F, \'{print int($4)}\'" }', root)
        proc.stdout.connect((data) => {
            root.brightness = parseInt(data)
            slider.value = root.brightness
        })
        proc.running = true
    }

    onExpandedChanged: {
        if (expanded) updateBrightness()
    }

    Timer {
        running: expanded
        repeat: true
        interval: 2000
        onTriggered: updateBrightness()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "󰃠"
            color: root.theme.primary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 100
            stepSize: 1
            onMoved: {
                let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "brightnessctl set " + slider.value + "%" }', root)
                proc.running = true
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 6
                width: slider.availableWidth
                height: implicitHeight
                radius: 3
                color: Qt.rgba(root.theme.surfaceHigh.r, root.theme.surfaceHigh.g, root.theme.surfaceHigh.b, 0.6)

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: root.theme.primary
                    radius: 3
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: slider.pressed ? root.theme.surfaceHigh : root.theme.text
                border.color: root.theme.primary
            }
        }
    }
}
