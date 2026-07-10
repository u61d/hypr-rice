import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property bool expanded: false

    implicitWidth: expanded ? 260 : 0
    implicitHeight: expanded ? Math.min(320, btList.contentHeight + header.height + 28) : 0
    radius: 16
    clip: true
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.92)
    border.width: 1
    border.color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.3)

    opacity: expanded ? 1 : 0
    visible: opacity > 0

    Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        visible: root.expanded

        RowLayout {
            id: header
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: "\ue1a7" // bluetooth
                color: Theme.secondary
                font.family: Fonts.icon
                font.pixelSize: 17
            }
            Text {
                text: "Bluetooth"
                color: Theme.text
                font.family: Fonts.sans
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 22
                radius: 11
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
            spacing: 6

            property var devices: []
            model: devices

            delegate: Rectangle {
                width: ListView.view.width
                height: 42
                radius: 10
                color: btMouse.containsMouse ? Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.4) : "transparent"

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: modelData.connected === "yes" ? "\ue1a8" : "\ue1a7" // bluetooth_connected / bluetooth
                        color: modelData.connected === "yes" ? Theme.secondary : Theme.muted
                        font.family: Fonts.icon
                        font.pixelSize: 16
                    }

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
                        visible: modelData.connected === "yes"
                        text: "Connected"
                        color: Theme.secondary
                        font.family: Fonts.sans
                        font.pixelSize: 10
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
                running: root.expanded
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
