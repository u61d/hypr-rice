import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData

    implicitWidth: 350
    implicitHeight: 500
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins {
        top: 50
        right: 10
    }
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
        let proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["cliphist", "list"] }', root)
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
        Quickshell.execDetached(["sh", "-c", "cliphist decode " + id + " | wl-copy"])
        globalState.clipboardVisible = false
    }

    function deleteItem(id) {
        deleteProc.command = ["cliphist", "delete", id]
        deleteProc.running = true
    }

    property string searchQuery: ""

    Process {
        id: deleteProc
        onExited: loadHistory()
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.95)
        border.width: 1
        border.color: Theme.primary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "\ue14f" // content_paste
                    color: Theme.primary
                    font.family: Fonts.icon
                    font.pixelSize: 16
                }

                Text {
                    text: "Clipboard History"
                    color: Theme.primary
                    font.family: Fonts.sans
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                MouseArea {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    hoverEnabled: true
                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd" // close
                        color: parent.containsMouse ? Theme.red : Theme.text
                        font.family: Fonts.icon
                        font.pixelSize: 15
                    }
                    onClicked: globalState.clipboardVisible = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.surfaceHigh
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search clipboard..."
                color: Theme.text
                placeholderTextColor: Theme.muted
                font.family: Fonts.sans
                font.pixelSize: 13
                padding: 8
                background: Rectangle {
                    radius: 8
                    color: Theme.surfaceHigh
                    border.width: 1
                    border.color: parent.activeFocus ? Theme.primary : "transparent"
                }
                onTextChanged: root.searchQuery = text.toLowerCase()
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: clipModel
                clip: true
                spacing: 4

                delegate: Rectangle {
                    width: parent.width
                    height: visible ? 40 : 0
                    visible: root.searchQuery === "" || (model.text || "").toLowerCase().includes(root.searchQuery)
                    opacity: visible ? 1 : 0
                    color: containsMouse ? Theme.surfaceHigh : "transparent"
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            text: model.text
                            color: Theme.text
                            font.family: Fonts.sans
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
                                text: "\ue92e" // delete
                                color: parent.containsMouse ? Theme.red : Theme.muted
                                font.family: Fonts.icon
                                font.pixelSize: 15
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
