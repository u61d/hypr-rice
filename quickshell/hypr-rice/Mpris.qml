import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

Rectangle {
    id: root

    // Only get players that can actually be controlled/read
    property var activePlayer: Mpris.players.values.find(p => p.canControl)
    
    // Hide completely if no player is active
    visible: activePlayer !== undefined
    
    Layout.preferredHeight: 28
    implicitWidth: visible && activePlayer ? (mouse.containsMouse ? 240 : Math.min(200, Math.max(100, row.implicitWidth + 24))) : 0
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : "transparent"
    border.width: 1
    border.color: mouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : "transparent"
    
    Behavior on implicitWidth { NumberAnimation { duration: 320; easing.type: Easing.OutExpo } }
    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 220 } }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        // Normal mode (collapsed)
        RowLayout {
            visible: !mouse.containsMouse
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: activePlayer && activePlayer.isPlaying ? "\ue034" : "\ue037" // pause / play_arrow
                color: Theme.primary
                font.family: Fonts.icon
                font.pixelSize: 16
            }

            Text {
                text: activePlayer ? (activePlayer.trackTitle || "Unknown") : ""
                color: Theme.text
                font.family: Fonts.sans
                font.pixelSize: 13
                font.weight: Font.Medium
                elide: Text.ElideRight
                Layout.maximumWidth: 150
            }
        }

        // Expanded mode (hover)
        ColumnLayout {
            visible: mouse.containsMouse
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ClippingWrapperRectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 10
                    color: "transparent"
                    visible: activePlayer && activePlayer.trackArtUrl != ""

                    Image {
                        anchors.fill: parent
                        source: activePlayer && activePlayer.trackArtUrl ? activePlayer.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    text: activePlayer ? (activePlayer.trackTitle || "Unknown") : ""
                    color: Theme.text
                    font.family: Fonts.sans
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                MouseArea {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: "\ue045" // skip_previous
                        color: parent.containsMouse ? Theme.primary : Theme.text
                        font.family: Fonts.icon
                        font.pixelSize: 16
                    }
                    hoverEnabled: true
                    onClicked: if(activePlayer) activePlayer.previous()
                }

                MouseArea {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: activePlayer && activePlayer.isPlaying ? "\ue034" : "\ue037" // pause / play_arrow
                        color: parent.containsMouse ? Theme.primary : Theme.text
                        font.family: Fonts.icon
                        font.pixelSize: 16
                    }
                    hoverEnabled: true
                    onClicked: if(activePlayer) activePlayer.isPlaying ? activePlayer.pause() : activePlayer.play()
                }

                MouseArea {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: "\ue044" // skip_next
                        color: parent.containsMouse ? Theme.primary : Theme.text
                        font.family: Fonts.icon
                        font.pixelSize: 16
                    }
                    hoverEnabled: true
                    onClicked: if(activePlayer) activePlayer.next()
                }
            }

            Rectangle {
                visible: !!(activePlayer && activePlayer.length > 0)
                Layout.fillWidth: true
                Layout.preferredHeight: 3
                radius: 1.5
                color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.6)

                Rectangle {
                    width: {
                        if (!activePlayer || !activePlayer.length) return 0
                        const pos = activePlayer.position || 0
                        const len = activePlayer.length
                        return len > 0 ? parent.width * (pos / len) : 0
                    }
                    height: parent.height
                    radius: 1.5
                    color: Theme.primary
                }
            }
        }
    }
}
