import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

PanelWindow {
    id: root
    required property var theme
    required property ShellScreen modelData
    screen: modelData
    anchors.fill: parent

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "powermenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.powerMenuVisible

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)

        // Dismiss on background click
        MouseArea {
            anchors.fill: parent
            onClicked: globalState.powerMenuVisible = false
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 24

            Repeater {
                model: ListModel {
                    ListElement { name: "Lock"; icon: ""; command: "hyprlock"; colorId: "primary" }
                    ListElement { name: "Logout"; icon: "󰍃"; command: "hyprctl dispatch exit"; colorId: "yellow" }
                    ListElement { name: "Suspend"; icon: "󰤄"; command: "systemctl suspend"; colorId: "blue" }
                    ListElement { name: "Hibernate"; icon: "󰋊"; command: "systemctl hibernate"; colorId: "green" }
                    ListElement { name: "Reboot"; icon: "󰜉"; command: "systemctl reboot"; colorId: "tertiary" }
                    ListElement { name: "Shutdown"; icon: "⏻"; command: "systemctl poweroff"; colorId: "red" }
                }

                delegate: Rectangle {
                    id: btnRect
                    width: 120
                    height: 120
                    radius: 20
                    color: Qt.rgba(root.theme.base.r, root.theme.base.g, root.theme.base.b, 0.8)
                    border.width: 1
                    border.color: hoverArea.containsMouse ? root.theme[model.colorId] : "transparent"

                    scale: hoverArea.pressed ? 0.95 : (hoverArea.containsMouse ? 1.05 : 1)
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: model.icon
                            color: hoverArea.containsMouse ? root.theme[model.colorId] : root.theme.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 36
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: model.name
                            color: root.theme.text
                            font.family: "Inter"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            globalState.powerMenuVisible = false
                            let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "' + model.command + '" }', root)
                            proc.running = true
                        }
                    }
                }
            }
        }
    }

    // Handle Escape key
    Item {
        focus: true
        Keys.onEscapePressed: globalState.powerMenuVisible = false
    }

    Connections {
        target: globalState
        function onPowerMenuVisibleChanged() {
            if (globalState.powerMenuVisible) {
                root.requestActivate()
            }
        }
    }
}
