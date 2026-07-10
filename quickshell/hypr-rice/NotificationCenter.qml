import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData

    implicitWidth: 380
    implicitHeight: 600
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins {
        top: 50
        right: 10
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifcenter"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.notificationCenterVisible

    ListModel {
        id: historyModel
    }

    Connections {
        target: Notifications
        function onNotificationAdded(n) {
            // Add to history
            historyModel.insert(0, {
                appName: n.appName,
                summary: n.summary,
                body: n.body,
                time: new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat),
                iconId: n.appName.toLowerCase()
            })
            // Keep max 50
            if (historyModel.count > 50) {
                historyModel.remove(50)
            }
        }
    }

    function getIcon(name) {
        let n = name.toLowerCase()
        if (n.includes("discord")) return "\ue0c9" // chat
        if (n.includes("firefox")) return "\ue80b" // public
        if (n.includes("spotify")) return "\ue405" // music_note
        if (n.includes("telegram")) return "\ue163" // send
        if (n.includes("thunderbird")) return "\ue159" // mail
        if (n.includes("grim")) return "\ue412" // photo_camera
        if (n.includes("volume") || n.includes("brightness")) return "\ue050" // volume_up
        return "\ue7f5" // notifications
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.95)
        border.width: 1
        border.color: Theme.primary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "\ue7f5" // notifications
                    color: Theme.primary
                    font.family: Fonts.icon
                    font.pixelSize: 18
                }

                Text {
                    text: "Notifications"
                    color: Theme.primary
                    font.family: Fonts.sans
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 28
                    radius: 8
                    color: Theme.surfaceHigh
                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: Theme.text
                        font.family: Fonts.sans
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: historyModel.clear()
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd" // close
                        color: parent.containsMouse ? Theme.red : Theme.text
                        font.family: Fonts.icon
                        font.pixelSize: 16
                    }
                    onClicked: globalState.notificationCenterVisible = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)
            }

            Text {
                text: "No new notifications"
                color: Theme.muted
                font.family: Fonts.sans
                font.pixelSize: 14
                visible: historyModel.count === 0
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: historyModel
                clip: true
                spacing: 8

                delegate: Rectangle {
                    width: parent.width
                    height: contentCol.implicitHeight + 24
                    color: Theme.surfaceHigh
                    radius: 12

                    ColumnLayout {
                        id: contentCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: getIcon(model.iconId)
                                color: Theme.primary
                                font.family: Fonts.icon
                                font.pixelSize: 16
                            }

                            Text {
                                text: model.appName || "Notification"
                                color: Theme.muted
                                font.family: Fonts.sans
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.time
                                color: Theme.muted
                                font.family: Fonts.sans
                                font.pixelSize: 10
                            }

                            MouseArea {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                cursorShape: Qt.PointingHandCursor
                                Text {
                                    anchors.centerIn: parent
                                    text: "\ue5cd" // close
                                    color: Theme.muted
                                    font.family: Fonts.icon
                                    font.pixelSize: 12
                                }
                                onClicked: historyModel.remove(index)
                            }
                        }

                        Text {
                            text: model.summary
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }

                        Text {
                            text: model.body
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            visible: text !== ""
                        }
                    }
                }
            }
        }
    }
}
