import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Rectangle {
    id: root
    required property var theme

    // Only get players that can actually be controlled/read
    property var activePlayer: Mpris.players.values.find(p => p.canControl)
    
    // Hide completely if no player is active
    visible: activePlayer !== undefined
    
    Layout.preferredHeight: 28
    implicitWidth: visible && activePlayer ? Math.min(300, Math.max(100, row.implicitWidth + 24)) : 0
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.18) : "transparent"
    scale: mouse.containsMouse ? 1.04 : 1

    Behavior on implicitWidth { NumberAnimation { duration: 320; easing.type: Easing.OutExpo } }
    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: activePlayer && activePlayer.isPlaying ? "󰏤" : "󰐊"
            color: root.theme.primary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: activePlayer ? (activePlayer.trackTitle || "Unknown") : ""
            color: root.theme.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
            Layout.maximumWidth: 200
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (activePlayer) {
                if (activePlayer.isPlaying) {
                    activePlayer.pause()
                } else {
                    activePlayer.play()
                }
            }
        }
    }
}
