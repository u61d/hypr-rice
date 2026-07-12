import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    required property var panelWindow
    required property string screenName

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Pill {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 9
                spacing: 4
                Workspaces {
                }
                ActiveWindow {
                    Layout.maximumWidth: 420
                }
            }
        }

        Item { Layout.fillWidth: true }

        Pill {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 9
                spacing: 10
                Mpris {}
                Cava {}
                Clock {}
            }
        }

        Item { Layout.fillWidth: true }

        Pill {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 9
                spacing: 4
                Tray {
                    panelWindow: root.panelWindow
                }
                StatusModule {
                    icon: ""
                    command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%d%%\", $2 * 100}'"
                    interval: 1500
                    clickCommand: "pavucontrol"
                }

                IconButton {
                    id: wifiIcon
                    icon: "\ue648"
                    onClicked: globalState.toggleOnly("network", globalState.networkMenuVisible)

                    Timer {
                        interval: 3000
                        running: true
                        repeat: true
                        onTriggered: wifiCheck.running = true
                    }

                    Process {
                        id: wifiCheck
                        command: ["sh", "-c", "nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d':' -f2 | head -n1"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                const sig = parseInt(text.trim())
                                if (isNaN(sig)) wifiIcon.icon = "\ue648"
                                else if (sig < 30) wifiIcon.icon = "\uebe4"
                                else if (sig < 60) wifiIcon.icon = "\uebd6"
                                else if (sig < 80) wifiIcon.icon = "\uebe1"
                                else wifiIcon.icon = "\ue63e"
                            }
                        }
                    }

                    Component.onCompleted: wifiCheck.running = true
                }

                IconButton {
                    id: btIcon
                    icon: "\ue1a7"
                    onClicked: globalState.toggleOnly("bluetooth", globalState.bluetoothMenuVisible)
                }

                IconButton {
                    icon: globalState.dndEnabled ? "\uf08f" : "\ue7f7"
                    accent: globalState.dndEnabled ? Theme.muted : Theme.primary
                    command: "qs -c hypr-rice ipc call hypr-rice toggleDnd"
                }

                IconButton {
                    icon: "\ue7f5"
                    accent: Theme.primary
                    command: "qs -c hypr-rice ipc call hypr-rice toggleNotificationCenter"
                }

                IconButton {
                    id: brightnessIcon
                    icon: "\ue3ab"
                    onClicked: globalState.toggleOnly("brightness", globalState.brightnessMenuVisible)
                }

                StatusModule {
                    icon: ""
                    accent: Theme.yellow
                    command: "checkupdates 2>/dev/null | wc -l || echo 0"
                    interval: 3600000
                    clickCommand: "kitty -e bash -lc 'checkupdates; echo; read -n1 -s -r -p \"Press any key...\"'"
                }
                StatusModule {
                    icon: ""
                    accent: Theme.green
                    command: "LC_ALL=C top -bn1 | awk '/Cpu/ {print int($2+$4)\"%\"}'" 
                    interval: 2500
                }
                StatusModule {
                    icon: ""
                    accent: Theme.yellow
                    command: "LC_ALL=C free | awk '/Mem:/ {printf \"%d%%\", $3/$2*100}'"
                    interval: 5000
                }
                StatusModule {
                    icon: ""
                    accent: Theme.secondary
                    command: "df -h / | awk 'NR==2 {gsub(/%/,\"\"); print $5\"%\"}'"
                    interval: 60000
                    thresholdColors: true
                }
                Battery { }
                IconButton {
                    icon: ""
                    accent: Theme.primary
                    command: "qs -c hypr-rice ipc call hypr-rice toggleClipboard"
                }
                IconButton {
                    icon: ""
                    accent: Theme.red
                    command: "qs -c hypr-rice ipc call hypr-rice togglePowerMenu"
                }
            }
        }
    }

    // Popups anchored to their trigger icons above. These live outside the
    // RowLayout because PopupWindow is a window, not a layoutable Item.
    NetworkMenu {
        anchorWindow: root.panelWindow
        triggerItem: wifiIcon
    }

    BluetoothMenu {
        anchorWindow: root.panelWindow
        triggerItem: btIcon
    }

    BrightnessMenu {
        anchorWindow: root.panelWindow
        triggerItem: brightnessIcon
    }
}