import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    required property var hypr
    required property var panelWindow
    required property string screenName

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Pill {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            theme: root.theme
            RowLayout {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 4
                Workspaces {
                    theme: root.theme
                    hypr: root.hypr
                }
                ActiveWindow {
                    theme: root.theme
                    hypr: root.hypr
                    Layout.maximumWidth: 420
                }
            }
        }

        Item { Layout.fillWidth: true }

        Pill {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            theme: root.theme
            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 10
                Mpris { theme: root.theme }
                Cava { theme: root.theme }
                Clock { theme: root.theme }
            }
        }

        Item { Layout.fillWidth: true }

        Pill {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            theme: root.theme
            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4
                Tray {
                    theme: root.theme
                    panelWindow: root.panelWindow
                }
                StatusModule {
                    theme: root.theme
                    icon: "󰕾"
                    command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%d%%\", $2 * 100}'"
                    interval: 1500
                    clickCommand: "pavucontrol"
                }

                // Wi-Fi icon with dropdown
                Item {
                    Layout.preferredWidth: wifiIcon.width
                    Layout.preferredHeight: 28
                    
                    IconButton {
                        id: wifiIcon
                        theme: root.theme
                        icon: "󰤨"
                        // Custom clicked signal handled here
                        property string command: ""
                        Timer {
                            interval: 3000
                            running: true
                            repeat: true
                            onTriggered: wifiCheck.running = true
                        }

                        // We can't nest Process directly in a standard QML Item without import Quickshell.Io
                        // so we'll instantiate it dynamically
                        property var wifiCheck: Qt.createQmlObject('import Quickshell.Io; Process { command: "nmcli -t -f active,signal dev wifi | grep \'^yes\' | cut -d\':\' -f2 | head -n1" }', wifiIcon)

                        Component.onCompleted: {
                            wifiIcon.children[1].clicked.connect(() => networkMenu.expanded = !networkMenu.expanded)
                            wifiCheck.stdout.connect((data) => {
                                let sig = parseInt(data)
                                if (isNaN(sig)) wifiIcon.icon = "󰤭"
                                else if (sig < 30) wifiIcon.icon = "󰤟"
                                else if (sig < 60) wifiIcon.icon = "󰤢"
                                else if (sig < 80) wifiIcon.icon = "󰤥"
                                else wifiIcon.icon = "󰤨"
                            })
                            wifiCheck.running = true
                        }
                    }
                    
                    NetworkMenu {
                        id: networkMenu
                        theme: root.theme
                        anchors.top: parent.bottom
                        anchors.topMargin: 12
                        anchors.right: parent.right
                    }
                }

                // Bluetooth icon with dropdown
                Item {
                    Layout.preferredWidth: btIcon.width
                    Layout.preferredHeight: 28
                    
                    IconButton {
                        id: btIcon
                        theme: root.theme
                        icon: "󰂯"
                        property string command: ""
                        Component.onCompleted: btIcon.children[1].clicked.connect(() => bluetoothMenu.expanded = !bluetoothMenu.expanded)
                    }
                    
                    BluetoothMenu {
                        id: bluetoothMenu
                        theme: root.theme
                        anchors.top: parent.bottom
                        anchors.topMargin: 12
                        anchors.right: parent.right
                    }
                }

                IconButton {
                    theme: root.theme
                    icon: globalState.dndEnabled ? "󰂛" : "󰂚"
                    accent: globalState.dndEnabled ? root.theme.muted : root.theme.primary
                    command: "quickshell ipc call hypr-rice toggleNotificationCenter"
                }

                // Brightness icon with dropdown
                Item {
                    Layout.preferredWidth: brightnessIcon.width
                    Layout.preferredHeight: 28
                    
                    IconButton {
                        id: brightnessIcon
                        theme: root.theme
                        icon: "󰃠"
                        property string command: ""
                        Component.onCompleted: brightnessIcon.children[1].clicked.connect(() => brightnessMenu.expanded = !brightnessMenu.expanded)
                    }
                    
                    BrightnessMenu {
                        id: brightnessMenu
                        theme: root.theme
                        anchors.top: parent.bottom
                        anchors.topMargin: 12
                        anchors.right: parent.right
                    }
                }

                StatusModule {
                    theme: root.theme
                    icon: "󰚰"
                    accent: root.theme.yellow
                    command: "checkupdates 2>/dev/null | wc -l || echo 0"
                    interval: 3600000 // 1 hour
                }
                StatusModule {
                    theme: root.theme
                    icon: "󰍛"
                    accent: root.theme.green
                    command: "top -bn1 | awk '/Cpu/ {print int($2+$4)\"%\"}'" 
                    interval: 2500
                }
                StatusModule {
                    theme: root.theme
                    icon: "󰘚"
                    accent: root.theme.yellow
                    command: "free | awk '/Mem:/ {printf \"%d%%\", $3/$2*100}'"
                    interval: 5000
                }
                StatusModule {
                    theme: root.theme
                    icon: "󰋊"
                    accent: root.theme.blue
                    command: "df -h / | awk 'NR==2 {print $5}'"
                    interval: 60000
                }
                Battery {
                    theme: root.theme
                }
                IconButton {
                    theme: root.theme
                    icon: "󰅌"
                    accent: root.theme.primary
                    command: "quickshell ipc call hypr-rice toggleClipboard"
                }
                IconButton {
                    theme: root.theme
                    icon: "⏻"
                    accent: root.theme.red
                    command: "quickshell ipc call hypr-rice togglePowerMenu"
                }
            }
        }
    }
}