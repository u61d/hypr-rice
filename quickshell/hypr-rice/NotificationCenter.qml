import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var theme
    required property ShellScreen modelData
    screen: modelData

    width: 380
    height: 600
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
        if (n.includes("discord")) return "󰙯"
        if (n.includes("firefox")) return "󰈹"
        if (n.includes("spotify")) return "󰓇"
        if (n.includes("telegram")) return ""
        if (n.includes("thunderbird")) return ""
        if (n.includes("grim")) return "󰄀"
        if (n.includes("volume") || n.includes("brightness")) return "󰕾"
        return "󰂚"
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.95)
        border.width: 1
        border.color: theme.primary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰂚 Notifications"
                    color: root.theme.primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 28
                    radius: 8
                    color: root.theme.surfaceHigh
                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: root.theme.text
                        font.family: "Inter"
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
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: parent.containsMouse ? root.theme.red : root.theme.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                    hoverEnabled: true
                    onClicked: globalState.notificationCenterVisible = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(root.theme.surfaceHigh.r, root.theme.surfaceHigh.g, root.theme.surfaceHigh.b, 0.5)
            }

            Text {
                text: "No new notifications"
                color: root.theme.muted
                font.family: "Inter"
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
                    color: root.theme.surfaceHigh
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
                                color: root.theme.primary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                            }

                            Text {
                                text: model.appName || "Notification"
                                color: root.theme.muted
                                font.family: "Inter"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.time
                                color: root.theme.muted
                                font.family: "Inter"
                                font.pixelSize: 10
                            }

                            MouseArea {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                cursorShape: Qt.PointingHandCursor
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    color: root.theme.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }
                                onClicked: historyModel.remove(index)
                            }
                        }

                        Text {
                            text: model.summary
                            color: root.theme.text
                            font.family: "Inter"
                            font.pixelSize: 14
                            font.bold: true
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }

                        Text {
                            text: model.body
                            color: root.theme.text
                            font.family: "Inter"
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
