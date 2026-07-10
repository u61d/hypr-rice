import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    // Notification popup column — top-right corner, stacking downward
    ColumnLayout {
        id: notifColumn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 16
        width: 380
        spacing: 10
        z: 999

        visible: !globalState.dndEnabled

        Repeater {
            model: Notifications.notifications

            Rectangle {
                id: card
                property bool isQuickshellReload: (modelData.appName === "quickshell" || modelData.appName === "Quickshell" || modelData.appName === "qs") && (modelData.summary || "").includes("Config reloaded")

                Layout.preferredWidth: isQuickshellReload ? 0 : 380
                Layout.preferredHeight: isQuickshellReload ? 0 : cardContent.implicitHeight + 28
                radius: 16
                clip: true
                visible: !isQuickshellReload

                // Glassmorphism
                color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.88)
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)

                // Subtle shadow via nested rect
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -1
                    radius: 17
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(0, 0, 0, 0.15)
                    z: -1
                }

                // --- Entry Animation: Slide in from the right with elastic bounce ---
                property real enterX: 0
                property real enterOpacity: 1

                transform: Translate { x: card.enterX }
                opacity: isQuickshellReload ? 0 : card.enterOpacity

                Component.onCompleted: {
                    enterX = 420
                    enterOpacity = 0
                    enterAnim.start()
                }

                ParallelAnimation {
                    id: enterAnim
                    NumberAnimation {
                        target: card; property: "enterX"
                        from: 420; to: 0
                        duration: 700; easing.type: Easing.OutElastic
                        easing.amplitude: 1.1; easing.period: 0.55
                    }
                    NumberAnimation {
                        target: card; property: "enterOpacity"
                        from: 0; to: 1
                        duration: 250; easing.type: Easing.OutCubic
                    }
                }

                // --- Content ---
                RowLayout {
                    id: cardContent
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14

                    // App Icon Circle
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        Layout.alignment: Qt.AlignTop
                        radius: 22
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                        Text {
                            anchors.centerIn: parent
                            text: {
                                const name = (modelData.appName || "").toLowerCase()
                                if (name.includes("discord")) return "\ue0c9" // chat
                                if (name.includes("firefox") || name.includes("browser")) return "\ue80b" // public
                                if (name.includes("spotify")) return "\ue405" // music_note
                                if (name.includes("telegram")) return "\ue163" // send
                                if (name.includes("thunderbird") || name.includes("mail")) return "\ue159" // mail
                                if (name.includes("screenshot") || name.includes("grim")) return "\ue412" // photo_camera
                                return "\ue7f5" // notifications
                            }
                            color: Theme.primary
                            font.family: Fonts.icon
                            font.pixelSize: 22
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        // App name label
                        Text {
                            text: modelData.appName || "Notification"
                            color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.7)
                            font.family: Fonts.sans
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }

                        // Summary (title)
                        Text {
                            text: modelData.summary || ""
                            color: Theme.text
                            font.family: Fonts.sans
                            font.weight: Font.DemiBold
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Body text
                        Text {
                            visible: (modelData.body || "").length > 0
                            text: modelData.body || ""
                            color: Theme.muted
                            font.family: Fonts.sans
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Close button
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignTop
                        radius: 12
                        color: closeBtn.containsMouse ? Theme.red : Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.6)
                        scale: closeBtn.containsMouse ? 1.15 : 1

                        Behavior on color { ColorAnimation { duration: 180 } }
                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                        Text {
                            anchors.centerIn: parent
                            text: "\ue5cd" // close
                            color: closeBtn.containsMouse ? Theme.base : Theme.text
                            font.family: Fonts.icon
                            font.pixelSize: 14
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }

                        MouseArea {
                            id: closeBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.close()
                        }
                    }
                }

                // Click to invoke default action
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: {
                        if (modelData.hasDefaultAction) modelData.invokeDefaultAction()
                    }
                }

                // Auto-dismiss after 6 seconds
                Timer {
                    running: true
                    interval: 6000
                    onTriggered: modelData.close()
                }
            }
        }
    }
}
