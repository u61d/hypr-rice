import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData

    implicitWidth: 320
    implicitHeight: 120
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins {
        top: 20
        right: 20
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screencapture"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: null
    visible: false

    property string imagePath: ""

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.9)
        border.width: 1
        border.color: Theme.primary

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Image {
                source: root.imagePath ? "file://" + root.imagePath : ""
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    text: "Screenshot Saved"
                    color: Theme.text
                    font.family: Fonts.sans
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignTop
                }

                Text {
                    text: root.imagePath.split("/").pop()
                    color: Theme.muted
                    font.family: Fonts.sans
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: Theme.surfaceHigh
                        Text {
                            anchors.centerIn: parent
                            text: "Copy"
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Quickshell.execDetached(["sh", "-c", "wl-copy < " + JSON.stringify(root.imagePath)])
                                root.visible = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: Theme.surfaceHigh
                        Text {
                            anchors.centerIn: parent
                            text: "Close"
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.visible = false
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.visible = false
    }

    Connections {
        target: screenshotBridge
        function onTickChanged() {
            if (screenshotBridge.path.length === 0) return
            root.imagePath = screenshotBridge.path
            root.visible = true
            hideTimer.restart()
        }
    }
}
