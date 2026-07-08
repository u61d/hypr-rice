import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Rectangle {
    id: root
    property bool expanded: false

    implicitWidth: expanded ? 280 : 0
    implicitHeight: expanded ? Math.min(360, wifiList.contentHeight + header.height + 28) : 0
    radius: 16
    clip: true
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.92)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

    opacity: expanded ? 1 : 0
    visible: opacity > 0

    Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        visible: root.expanded

        // Header
        RowLayout {
            id: header
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: "󰤨  Wi-Fi"
                color: Theme.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 22
                radius: 11
                color: Theme.primary

                Text {
                    anchors.centerIn: parent
                    text: "ON"
                    color: Theme.base
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.4)
        }

        // Network list
        ListView {
            id: wifiList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6

            property var networks: []

            model: networks

            delegate: Rectangle {
                width: ListView.view.width
                height: 42
                radius: 10
                color: netMouse.containsMouse ? Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.4) : "transparent"

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10
                    Text {
                        text: {
                            const sig = parseInt(modelData.signal || 0)
                            if (sig > 75) return "󰤨"
                            if (sig > 50) return "󰤥"
                            if (sig > 25) return "󰤢"
                            return "󰤟"
                        }
                        color: modelData.active === "yes" ? Theme.green : Theme.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: modelData.ssid || "Hidden"
                            color: Theme.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: modelData.active === "yes"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: modelData.active === "yes"
                            text: "Connected"
                            color: Theme.green
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }
                    }
                    Text {
                        text: (modelData.signal || "0") + "%"
                        color: Theme.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.active !== "yes") {
                            Quickshell.exec("nmcli dev wifi connect '" + modelData.ssid + "'")
                        }
                    }
                }
            }

            // Fetch Wi-Fi list via nmcli
            Process {
                id: wifiScanner
                running: root.expanded
                command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,ACTIVE dev wifi list 2>/dev/null | head -15"]
                stdout: SplitParser {
                    splitMarker: ""
                    onRead: data => {
                        const lines = data.trim().split("\n").filter(l => l)
                        const parsed = lines.map(l => {
                            const parts = l.split(":")
                            return { ssid: parts[0], signal: parts[1], active: parts[2] }
                        }).filter(n => n.ssid)
                        // Sort: connected first, then by signal
                        parsed.sort((a, b) => {
                            if (a.active === "yes") return -1
                            if (b.active === "yes") return 1
                            return parseInt(b.signal) - parseInt(a.signal)
                        })
                        wifiList.networks = parsed
                    }
                }
            }
        }
    }
}
