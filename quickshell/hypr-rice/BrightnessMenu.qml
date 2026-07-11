import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData
    property int brightness: 0

    implicitWidth: 240
    implicitHeight: 80
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins {
        top: 50
        right: 10
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "brightness-menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.brightnessMenuVisible

    function updateBrightness() {
        if (!brightnessProc.running) brightnessProc.running = true
    }

    Process {
        id: brightnessProc
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{print int($4)}'"]
        stdout: SplitParser {
            onRead: data => {
                root.brightness = parseInt(data)
                slider.value = root.brightness
            }
        }
    }

    onVisibleChanged: {
        if (visible) updateBrightness()
    }

    Timer {
        running: root.visible
        repeat: true
        interval: 2000
        onTriggered: updateBrightness()
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "\ue3ab" // brightness_6
                color: Theme.primary
                font.family: Fonts.icon
                font.pixelSize: 18
            }

            Slider {
                id: slider
                Layout.fillWidth: true
                from: 0
                to: 100
                stepSize: 1
                onMoved: {
                    Quickshell.execDetached(["brightnessctl", "set", slider.value + "%"])
                }

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: slider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.6)

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: Theme.primary
                        radius: 3
                    }
                }

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: slider.pressed ? Theme.surfaceHigh : Theme.text
                    border.color: Theme.primary
                }
            }
        }
    }
}
