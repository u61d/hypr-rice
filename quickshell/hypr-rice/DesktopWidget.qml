import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    required property var theme

    anchors.fill: parent

    // === Giant Clock ===
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: clockText
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(new Date(), "hh:mm")
            color: Qt.rgba(root.theme.text.r, root.theme.text.g, root.theme.text.b, 0.25)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 200
            font.weight: Font.Black
            
            Behavior on color { ColorAnimation { duration: 500 } }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -20
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            color: Qt.rgba(root.theme.text.r, root.theme.text.g, root.theme.text.b, 0.15)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 22
            font.weight: Font.Medium
        }

        Text {
            id: greetingText
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 24
            text: {
                const h = new Date().getHours()
                if (h < 6) return "Good Night  󰖔"
                if (h < 12) return "Good Morning  "
                if (h < 18) return "Good Afternoon  󰖨"
                return "Good Evening  󰖔"
            }
            color: Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.50)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            font.weight: Font.Bold
        }

        Weather {
            theme: root.theme
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 32
        }
    }

    // === Subtle background Cava visualizer ===
    Row {
        id: bgCava
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 60
        spacing: 6
        
        property var values: []

        Repeater {
            model: 24
            Rectangle {
                width: 12
                height: Math.max(3, (bgCava.values[index] || 0) * 1.8)
                anchors.bottom: parent.bottom
                color: Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.12)
                radius: 6

                Behavior on height {
                    NumberAnimation { duration: 140; easing.type: Easing.OutSine }
                }
            }
        }

        Process {
            running: true
            command: [Quickshell.shellPath("scripts/cava.sh")]
            stdout: SplitParser {
                onRead: data => {
                    const text = data.trim()
                    if (text) {
                        const parts = text.split(",").map(Number)
                        while (parts.length < 24) parts.push(0)
                        bgCava.values = parts.slice(0, 24)
                    }
                }
            }
        }
    }

    // Update clock every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }
}
