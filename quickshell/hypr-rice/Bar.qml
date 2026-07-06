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
                        Component.onCompleted: wifiIcon.children[1].clicked.connect(() => networkMenu.expanded = !networkMenu.expanded)
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
                IconButton {
                    theme: root.theme
                    icon: "⏻"
                    accent: root.theme.red
                    command: "wlogout"
                }
            }
        }
    }
}