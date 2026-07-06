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
    implicitWidth: visible && activePlayer ? (mouse.containsMouse ? 240 : Math.min(200, Math.max(100, row.implicitWidth + 24))) : 0
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.18) : "transparent"
    border.width: 1
    border.color: mouse.containsMouse ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.4) : "transparent"
    
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
                Layout.maximumWidth: 150
            }
        }

        // Expanded mode (hover)
        RowLayout {
            visible: mouse.containsMouse
            Layout.fillWidth: true
            spacing: 8

            Image {
                source: activePlayer && activePlayer.trackArtUrl ? activePlayer.trackArtUrl : ""
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                fillMode: Image.PreserveAspectCrop
                visible: source != ""
                layer.enabled: true
                layer.effect: ShaderEffect {
                    fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        void main() {
                            vec4 color = texture2D(source, qt_TexCoord0);
                            vec2 d = qt_TexCoord0 - vec2(0.5, 0.5);
                            float r = length(d);
                            if (r > 0.5) discard;
                            gl_FragColor = color * qt_Opacity;
                        }
                    "
                }
            }

            Text {
                text: activePlayer ? (activePlayer.trackTitle || "Unknown") : ""
                color: root.theme.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            MouseArea {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                cursorShape: Qt.PointingHandCursor
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: parent.containsMouse ? root.theme.primary : root.theme.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
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
                    text: activePlayer && activePlayer.isPlaying ? "󰏤" : "󰐊"
                    color: parent.containsMouse ? root.theme.primary : root.theme.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
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
                    text: "󰒭"
                    color: parent.containsMouse ? root.theme.primary : root.theme.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                }
                hoverEnabled: true
                onClicked: if(activePlayer) activePlayer.next()
            }
        }
    }
}
