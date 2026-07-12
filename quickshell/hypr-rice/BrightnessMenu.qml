import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    required property var anchorWindow
    required property Item triggerItem
    property int brightness: 50

    implicitWidth: 280
    implicitHeight: 110
    color: "transparent"
    visible: globalState.brightnessMenuVisible

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow.contentItem.mapFromItem(triggerItem, triggerItem.width / 2, 0).x - implicitWidth / 2
    anchor.rect.y: anchorWindow.contentItem.mapFromItem(triggerItem, 0, triggerItem.height).y + 10

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
        if (visible) {
            pop.scale = 0.85
            pop.opacity = 0
            scaleAnim.restart()
            updateBrightness()
        }
    }

    Timer {
        running: root.visible
        repeat: true
        interval: 2000
        onTriggered: updateBrightness()
    }

    Item {
        id: pop
        anchors.fill: parent
        scale: 0.85
        opacity: 0
        transformOrigin: Item.Top

        ParallelAnimation {
            id: scaleAnim
            running: false
            NumberAnimation { target: pop; property: "scale"; to: 1; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.6 }
            NumberAnimation { target: pop; property: "opacity"; to: 1; duration: 160; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.96)
            border.width: 1
            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 10
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)
                        Text {
                            anchors.centerIn: parent
                            text: "\ue3ab" // brightness_6
                            color: Theme.primary
                            font.family: Fonts.icon
                            font.pixelSize: 18
                        }
                    }
                    Text {
                        text: "Brightness"
                        color: Theme.text
                        font.family: Fonts.sans
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(slider.value) + "%"
                        color: Theme.primary
                        font.family: Fonts.sans
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: "\ue3ab"
                        color: Theme.muted
                        font.family: Fonts.icon
                        font.pixelSize: 13
                    }

                    Slider {
                        id: slider
                        Layout.fillWidth: true
                        from: 5
                        to: 100
                        stepSize: 1
                        onMoved: {
                            Quickshell.execDetached(["brightnessctl", "set", Math.round(slider.value) + "%"])
                        }

                        background: Rectangle {
                            x: slider.leftPadding
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 8
                            width: slider.availableWidth
                            height: implicitHeight
                            radius: 4
                            color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.6)

                            Rectangle {
                                width: slider.visualPosition * parent.width
                                height: parent.height
                                radius: 4
                                color: Theme.primary
                            }
                        }

                        handle: Rectangle {
                            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            implicitWidth: 18
                            implicitHeight: 18
                            radius: 9
                            color: slider.pressed ? Theme.surfaceHigh : Theme.text
                            border.width: 2
                            border.color: Theme.primary

                            Behavior on implicitWidth { NumberAnimation { duration: 120 } }
                        }
                    }
                }
            }
        }
    }
}
