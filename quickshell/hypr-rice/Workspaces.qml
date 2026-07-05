import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var theme
    required property var hypr

    spacing: 3

    Repeater {
        model: 10

        Rectangle {
            id: button

            required property int index

            readonly property int workspaceId: index + 1
            readonly property bool active: root.hypr.activeWorkspace === workspaceId
            readonly property bool occupied: root.hypr.workspaces.some(workspace => workspace.id === workspaceId && workspace.windows > 0)

            implicitWidth: active ? 34 : 25
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: 26
            radius: 10
            color: active ? root.theme.primary : (occupied ? Qt.rgba(root.theme.secondary.r, root.theme.secondary.g, root.theme.secondary.b, 0.18) : "transparent")
            border.width: occupied && !active ? 1 : 0
            border.color: Qt.rgba(root.theme.secondary.r, root.theme.secondary.g, root.theme.secondary.b, 0.35)
            scale: mouse.containsMouse ? 1.08 : 1

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutBack
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent
                text: button.active ? "󰮯" : (button.occupied ? "󰺵" : "·")
                color: button.active ? root.theme.mantle : root.theme.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: button.active ? 15 : 14
                font.bold: true
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.hypr.dispatch("workspace " + button.workspaceId)
            }
        }
    }
}
