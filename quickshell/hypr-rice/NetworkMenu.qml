import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData

    implicitWidth: 320
    implicitHeight: Math.min(360, wifiList.contentHeight + header.height + 28)
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins {
        top: 50
        right: 10
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "network-menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.networkMenuVisible

    Rectangle {
        anchors.fill: parent
        radius: 16
        clip: true
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "\ue63e" // wifi
                    color: Theme.primary
                    font.family: Fonts.icon
                    font.pixelSize: 17
                }
                Text {
                    text: "Wi-Fi"
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
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "ON"
                        color: Theme.base
                        font.family: Fonts.sans
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }
                MouseArea {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    hoverEnabled: true
                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd" // close
                        color: parent.containsMouse ? Theme.red : Theme.text
                        font.family: Fonts.icon
                        font.pixelSize: 15
                    }
                    onClicked: globalState.networkMenuVisible = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.4)
            }

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
                                if (sig > 75) return "\ue63e" // wifi
                                if (sig > 50) return "\uebe1" // network_wifi_3_bar
                                if (sig > 25) return "\uebd6" // network_wifi_2_bar
                                return "\uebe4" // network_wifi_1_bar
                            }
                            color: modelData.active === "yes" ? Theme.green : Theme.muted
                            font.family: Fonts.icon
                            font.pixelSize: 16
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: modelData.ssid || "Hidden"
                                color: Theme.text
                                font.family: Fonts.sans
                                font.pixelSize: 13
                                font.weight: modelData.active === "yes" ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                visible: modelData.active === "yes"
                                text: "Connected"
                                color: Theme.green
                                font.family: Fonts.sans
                                font.pixelSize: 10
                            }
                        }
                        Text {
                            text: (modelData.signal || "0") + "%"
                            color: Theme.muted
                            font.family: Fonts.sans
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
                                Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", modelData.ssid])
                            }
                        }
                    }
                }

                Process {
                    id: wifiScanner
                    running: root.visible
                    command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,ACTIVE dev wifi list 2>/dev/null | head -15"]
                    stdout: SplitParser {
                        splitMarker: ""
                        onRead: data => {
                            const lines = data.trim().split("\n").filter(l => l)
                            const parsed = lines.map(l => {
                                const parts = l.split(":")
                                return { ssid: parts[0], signal: parts[1], active: parts[2] }
                            }).filter(n => n.ssid)
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
}
