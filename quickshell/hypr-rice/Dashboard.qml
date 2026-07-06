import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    id: root
    required property var theme
    required property var win

    anchors.fill: parent
    color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.72)

    // Fade in/out
    opacity: win.visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // Click background to dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: win.visible = false
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            win.visible = false
            event.accepted = true
        }
    }

    // === Central Card ===
    Rectangle {
        id: mainCard
        anchors.centerIn: parent
        width: 900
        height: 640
        radius: 24
        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.55)
        border.width: 1
        border.color: Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.25)

        // Entry animation
        scale: win.visible ? 1 : 0.88
        opacity: win.visible ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 20

            // ==== Search Bar ====
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 460
                Layout.preferredHeight: 48
                radius: 14
                color: Qt.rgba(root.theme.base.r, root.theme.base.g, root.theme.base.b, 0.85)
                border.width: searchInput.activeFocus ? 2 : 1
                border.color: searchInput.activeFocus ? root.theme.primary : Qt.rgba(root.theme.surfaceHigh.r, root.theme.surfaceHigh.g, root.theme.surfaceHigh.b, 0.5)

                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    Text {
                        text: "󰍉"
                        color: root.theme.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                    }
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: root.theme.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        clip: true
                        Text {
                            anchors.fill: parent
                            text: "Search apps..."
                            color: root.theme.muted
                            font: searchInput.font
                            visible: !searchInput.text && !searchInput.activeFocus
                        }
                        onAccepted: {
                            if (filteredApps.count > 0) {
                                filteredApps.values[0].execute()
                                win.visible = false
                                searchInput.text = ""
                            }
                        }
                    }
                }
            }

            // ==== Top Widget Row: Now Playing + System Stats ====
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                spacing: 16

                // Now Playing Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: Qt.rgba(root.theme.base.r, root.theme.base.g, root.theme.base.b, 0.7)
                    border.width: 1
                    border.color: Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.2)

                    property var player: Mpris.players.values.find(p => p.canControl)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        // Album art placeholder
                        Rectangle {
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 70
                            radius: 12
                            color: Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.12)
                            Text {
                                anchors.centerIn: parent
                                text: "󰎈"
                                color: root.theme.primary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 32
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "NOW PLAYING"
                                color: root.theme.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                            Text {
                                text: parent.parent.parent.parent.player ? parent.parent.parent.parent.player.trackTitle || "Nothing playing" : "Nothing playing"
                                color: root.theme.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 15
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: parent.parent.parent.parent.player ? parent.parent.parent.parent.player.trackArtist || "—" : "—"
                                color: root.theme.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // CPU Meter
                Rectangle {
                    Layout.preferredWidth: 130
                    Layout.fillHeight: true
                    radius: 16
                    color: Qt.rgba(root.theme.base.r, root.theme.base.g, root.theme.base.b, 0.7)
                    border.width: 1
                    border.color: Qt.rgba(root.theme.green.r, root.theme.green.g, root.theme.green.b, 0.2)

                    property string cpuValue: "0"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "CPU"
                            color: root.theme.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: parent.parent.cpuValue + "%"
                            color: root.theme.green
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    Process {
                        running: win.visible
                        command: ["bash", "-c", "top -bn1 | awk '/Cpu/ {print int($2+$4)}'"]
                        stdout: SplitParser {
                            onRead: data => { parent.parent.cpuValue = data.trim() }
                        }
                    }
                }

                // RAM Meter
                Rectangle {
                    Layout.preferredWidth: 130
                    Layout.fillHeight: true
                    radius: 16
                    color: Qt.rgba(root.theme.base.r, root.theme.base.g, root.theme.base.b, 0.7)
                    border.width: 1
                    border.color: Qt.rgba(root.theme.yellow.r, root.theme.yellow.g, root.theme.yellow.b, 0.2)

                    property string ramValue: "0"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "RAM"
                            color: root.theme.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: parent.parent.ramValue + "%"
                            color: root.theme.yellow
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    Process {
                        running: win.visible
                        command: ["bash", "-c", "free | awk '/Mem:/ {printf \"%d\", $3/$2*100}'"]
                        stdout: SplitParser {
                            onRead: data => { parent.parent.ramValue = data.trim() }
                        }
                    }
                }
            }

            // ==== App Grid ====
            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 110
                cellHeight: 110
                clip: true

                model: ScriptModel {
                    id: filteredApps
                    values: {
                        const allEntries = [...DesktopEntries.applications.values]
                            .filter(d => d.name)
                            .sort((a, b) => a.name.localeCompare(b.name))

                        const q = searchInput.text.trim().toLowerCase()
                        if (q === "") return allEntries

                        return allEntries.filter(d =>
                            (d.name || "").toLowerCase().includes(q) ||
                            (d.comment || "").toLowerCase().includes(q)
                        )
                    }
                }

                delegate: Item {
                    width: appGrid.cellWidth
                    height: appGrid.cellHeight

                    Rectangle {
                        id: appCard
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 14
                        color: appMouse.containsMouse ? Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.12) : "transparent"
                        scale: appMouse.pressed ? 0.92 : (appMouse.containsMouse ? 1.06 : 1)

                        Behavior on color { ColorAnimation { duration: 180 } }
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            // Icon
                            Image {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                Layout.alignment: Qt.AlignHCenter
                                source: Quickshell.iconPath(modelData.icon || "application-x-executable", true)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                text: modelData.name
                                color: root.theme.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                Layout.preferredWidth: 86
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.execute()
                                win.visible = false
                                searchInput.text = ""
                            }
                        }
                    }
                }
            }
        }
    }

    // Focus search when opened
    Connections {
        target: win
        function onVisibleChanged() {
            if (win.visible) searchInput.forceActiveFocus()
            else searchInput.text = ""
        }
    }
}
