import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    required property var anchorWindow
    required property Item triggerItem

    implicitWidth: 320
    implicitHeight: Math.min(340, btList.contentHeight + header.height + 40)
    color: "transparent"
    visible: globalState.bluetoothMenuVisible

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow.contentItem.mapFromItem(triggerItem, triggerItem.width / 2, 0).x - implicitWidth / 2
    anchor.rect.y: anchorWindow.contentItem.mapFromItem(triggerItem, 0, triggerItem.height).y + 10

    onVisibleChanged: {
        if (visible) {
            pop.scale = 0.85
            pop.opacity = 0
            scaleAnim.restart()
        }
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
            clip: true
            color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.96)
            border.width: 1
            border.color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.35)

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 60
                radius: 18
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.14) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    id: header
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 10
                        color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.18)
                        Text {
                            anchors.centerIn: parent
                            text: "\ue1a7" // bluetooth
                            color: Theme.secondary
                            font.family: Fonts.icon
                            font.pixelSize: 18
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: "Bluetooth"
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: btList.count + " paired device" + (btList.count === 1 ? "" : "s")
                            color: Theme.muted
                            font.family: Fonts.sans
                            font.pixelSize: 11
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 24
                        radius: 12
                        color: Theme.secondary
                        Text {
                            anchors.centerIn: parent
                            text: "ON"
                            color: Theme.base
                            font.family: Fonts.sans
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.4)
                }

                ListView {
                    id: btList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4

                    property var devices: []
                    model: devices

                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                    }

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 46
                        radius: 12
                        color: btMouse.containsMouse ? Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5) : "transparent"

                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 9
                                color: modelData.connected === "yes"
                                    ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.18)
                                    : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.12)
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.connected === "yes" ? "\ue1a8" : "\ue1a7"
                                    color: modelData.connected === "yes" ? Theme.secondary : Theme.muted
                                    font.family: Fonts.icon
                                    font.pixelSize: 15
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: modelData.name || modelData.address
                                    color: Theme.text
                                    font.family: Fonts.sans
                                    font.pixelSize: 13
                                    font.weight: modelData.connected === "yes" ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.connected === "yes" ? "Connected" : "Not connected"
                                    color: modelData.connected === "yes" ? Theme.secondary : Theme.muted
                                    font.family: Fonts.sans
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: btMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.connected === "yes") {
                                    Quickshell.execDetached(["bluetoothctl", "disconnect", modelData.address])
                                } else {
                                    Quickshell.execDetached(["bluetoothctl", "connect", modelData.address])
                                }
                            }
                        }
                    }

                    Process {
                        running: root.visible
                        command: ["bash", "-c", "bluetoothctl devices Paired 2>/dev/null | while read _ addr name; do conn=$(bluetoothctl info \"$addr\" 2>/dev/null | grep 'Connected:' | awk '{print $2}'); echo \"$addr:$name:$conn\"; done"]
                        stdout: SplitParser {
                            splitMarker: ""
                            onRead: data => {
                                const lines = data.trim().split("\n").filter(l => l)
                                const parsed = lines.map(l => {
                                    const parts = l.split(":")
                                    return { address: parts[0], name: parts[1], connected: parts[2] }
                                }).filter(d => d.address)
                                parsed.sort((a, b) => {
                                    if (a.connected === "yes") return -1
                                    if (b.connected === "yes") return 1
                                    return a.name.localeCompare(b.name)
                                })
                                btList.devices = parsed
                            }
                        }
                    }
                }
            }
        }
    }
}
