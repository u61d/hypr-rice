import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

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
                    ListElement { name: "Lock"; icon: "\ue899"; command: "hyprlock"; colorId: "primary" }
                    ListElement { name: "Logout"; icon: "\ue9ba"; command: "hyprctl dispatch exit"; colorId: "yellow" }
                    ListElement { name: "Suspend"; icon: "\uf159"; command: "systemctl suspend"; colorId: "secondary" }
                    ListElement { name: "Hibernate"; icon: "\ue161"; command: "systemctl hibernate"; colorId: "green" }
                    ListElement { name: "Reboot"; icon: "\uf053"; command: "systemctl reboot"; colorId: "tertiary" }
                    ListElement { name: "Shutdown"; icon: "\uf8c7"; command: "systemctl poweroff"; colorId: "red" }
                }

                delegate: Rectangle {
                    id: btnRect
                    width: 120
                    height: 120
                    radius: 20
                    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.8)
                    border.width: 1
                    border.color: hoverArea.containsMouse ? Theme[model.colorId] : "transparent"

                    scale: hoverArea.pressed ? 0.95 : (hoverArea.containsMouse ? 1.05 : 1)
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: model.icon
                            color: hoverArea.containsMouse ? Theme[model.colorId] : Theme.text
                            font.family: Fonts.icon
                            font.pixelSize: 34
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: model.name
                            color: Theme.text
                            font.family: Fonts.sans
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
                            Quickshell.execDetached(["sh", "-c", model.command])
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
