import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    required property var theme
    required property ShellScreen modelData
    screen: modelData

    width: 350
    height: 500
    color: "transparent"
    anchors.top: true
    anchors.right: true
    anchors.topMargin: 50
    anchors.rightMargin: 10
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clipboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.clipboardVisible

    // Watch global state from shell.qml
    Connections {
        target: globalState
        function onClipboardVisibleChanged() {
            if (globalState.clipboardVisible) {
                loadHistory()
            }
        }
    }

    ListModel {
        id: clipModel
    }

    function loadHistory() {
        let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "cliphist list" }', root)
        proc.stdout.connect((data) => {
            clipModel.clear()
            let lines = data.split('\n')
            for (let i = 0; i < Math.min(20, lines.length); i++) {
                if (lines[i].trim() !== "") {
                    let parts = lines[i].split('\t')
                    if (parts.length >= 2) {
                        clipModel.append({ id: parts[0], text: parts[1] })
                    }
                }
            }
        })
        proc.running = true
    }

    function pasteItem(id) {
        let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "cliphist decode " + id + " | wl-copy" }', root)
        proc.running = true
        globalState.clipboardVisible = false
    }

    function deleteItem(id) {
        let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: "cliphist decode " + id + " | cliphist delete" }', root)
        proc.exited.connect(() => { loadHistory() })
        proc.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.95)
        border.width: 1
        border.color: theme.primary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰅌 Clipboard History"
                    color: root.theme.primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                }
                MouseArea {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: parent.containsMouse ? root.theme.red : root.theme.text
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    hoverEnabled: true
                    onClicked: globalState.clipboardVisible = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: root.theme.surfaceHigh
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: clipModel
                clip: true
                spacing: 4

                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    color: containsMouse ? root.theme.surfaceHigh : "transparent"
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            text: model.text
                            color: root.theme.text
                            font.family: "Inter"
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        MouseArea {
                            id: deleteBtn
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            hoverEnabled: true
                            visible: parentItem.containsMouse
                            Text {
                                anchors.centerIn: parent
                                text: "󰆴"
                                color: parent.containsMouse ? root.theme.red : root.theme.muted
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            onClicked: deleteItem(model.id)
                        }
                    }

                    property var parentItem: this
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: pasteItem(model.id)
                        // Ignore events over the delete button
                        z: -1
                    }
                }
            }
        }
    }
}
