import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    required property var theme
    required property ShellScreen modelData
    screen: modelData

    width: 320
    height: 120
    color: "transparent"
    anchors.top: true
    anchors.right: true
    anchors.topMargin: 20
    anchors.rightMargin: 20
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screencapture"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: null
    visible: false

    property string imagePath: ""

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.9)
        border.width: 1
        border.color: theme.primary

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
                layer.enabled: true
                layer.effect: ShaderEffect {
                    fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        void main() {
                            gl_FragColor = texture2D(source, qt_TexCoord0) * qt_Opacity;
                        }
                    "
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    text: "Screenshot Saved"
                    color: root.theme.text
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignTop
                }

                Text {
                    text: root.imagePath.split("/").pop()
                    color: root.theme.muted
                    font.family: "Inter"
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
                        color: root.theme.surfaceHigh
                        Text {
                            anchors.centerIn: parent
                            text: "Copy"
                            color: root.theme.text
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "wl-copy < " + root.imagePath }', root)
                                proc.running = true
                                root.visible = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: root.theme.surfaceHigh
                        Text {
                            anchors.centerIn: parent
                            text: "Close"
                            color: root.theme.text
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
        target: Ipc
        function onMessageReceived(msg) {
            if (msg.startsWith("screenshot:")) {
                root.imagePath = msg.split(":")[1]
                root.visible = true
                hideTimer.restart()
            }
        }
    }
}
