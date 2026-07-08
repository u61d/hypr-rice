import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 3

    Repeater {
        // Dynamically scale up if a workspace > 10 is opened
        model: Math.max(10, HyprState.workspaces.reduce((max, w) => Math.max(max, w.id), 0))

        Rectangle {
            id: button
            required property int index
            readonly property int workspaceId: index + 1
            readonly property bool active: HyprState.activeWorkspace === workspaceId
            readonly property bool occupied: HyprState.workspaces.some(workspace => workspace.id === workspaceId && workspace.windows > 0)

            // Get the list of window classes on this workspace
            readonly property var windowClasses: {
                const ws = HyprState.workspaces.find(w => w.id === workspaceId)
                return ws && ws.windowClasses ? ws.windowClasses : []
            }

            implicitWidth: active ? 34 : 25
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: 26
            radius: 10
            
            color: active ? Theme.primary : (occupied ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.18) : "transparent")
            border.width: occupied && !active ? 1 : 0
            border.color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.35)
            scale: mouse.containsMouse ? 1.08 : 1

            Behavior on implicitWidth { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Text {
                anchors.centerIn: parent
                text: button.active ? "󰮯" : (button.occupied ? "󰺵" : "·")
                color: button.active ? Theme.mantle : Theme.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: button.active ? 15 : 14
                font.bold: true
            }

            // === Workspace Tooltip Preview ===
            Rectangle {
                id: tooltip
                visible: mouse.containsMouse && button.occupied && !button.active
                anchors.top: parent.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: tooltipContent.implicitWidth + 20
                height: tooltipContent.implicitHeight + 14
                radius: 10
                color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.92)
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                z: 100

                opacity: visible ? 1 : 0
                scale: visible ? 1 : 0.85
                transformOrigin: Item.Top

                Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                RowLayout {
                    id: tooltipContent
                    anchors.centerIn: parent
                    spacing: 6

                    Repeater {
                        model: button.windowClasses

                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 7
                            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    const cls = (modelData || "").toLowerCase()
                                    if (cls.includes("kitty") || cls.includes("terminal")) return ""
                                    if (cls.includes("firefox") || cls.includes("browser")) return "󰈹"
                                    if (cls.includes("chromium") || cls.includes("chrome")) return ""
                                    if (cls.includes("discord")) return "󰙯"
                                    if (cls.includes("spotify")) return "󰓇"
                                    if (cls.includes("code") || cls.includes("cursor")) return "󰨞"
                                    if (cls.includes("nautilus") || cls.includes("files")) return "󰉋"
                                    if (cls.includes("telegram")) return ""
                                    if (cls.includes("steam")) return "󰓓"
                                    if (cls.includes("obs")) return "󰑋"
                                    if (cls.includes("gimp")) return "󰃣"
                                    if (cls.includes("blender")) return "󰂫"
                                    return "󰣆"
                                }
                                color: Theme.primary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: HyprState.dispatch("workspace " + button.workspaceId)
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        HyprState.dispatch("workspace e-1")
                    } else if (wheel.angleDelta.y < 0) {
                        HyprState.dispatch("workspace e+1")
                    }
                }
            }
        }
    }
}