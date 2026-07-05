import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: root

    required property var theme
    required property var panelWindow

    spacing: 2
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: trayButton

            required property SystemTrayItem modelData

            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 10
            color: mouse.containsMouse ? Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.18) : "transparent"
            scale: mouse.containsMouse ? 1.08 : 1

            Behavior on color {
                ColorAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: Quickshell.iconPath(trayButton.modelData.icon, true)
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: event => {
                    if (event.button === Qt.RightButton && trayButton.modelData.hasMenu)
                        trayButton.modelData.display(root.panelWindow, trayButton.x, trayButton.y + trayButton.height)
                    else
                        trayButton.modelData.activate()
                }
            }
        }
    }
}
