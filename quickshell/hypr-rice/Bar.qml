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

        Item {
            Layout.fillWidth: true
        }

        Pill {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            theme: root.theme

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 10

                Cava {
                    theme: root.theme
                }

                Clock {
                    theme: root.theme
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

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

                StatusModule {
                    theme: root.theme
                    icon: "󰤨"
                    command: "nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1==\"yes\" {print $2 \"%\"; found=1} END {if (!found) print \"off\"}'"
                    interval: 4000
                }

                StatusModule {
                    theme: root.theme
                    icon: "󰍛"
                    accent: root.theme.green
                    command: "top -bn1 | awk '/Cpu/ {printf \"%d%%\", 100 - $8}'"
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
                    icon: "󰂚"
                    command: "swaync-client -t -sw"
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
