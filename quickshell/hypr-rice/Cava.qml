import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Text {
    id: root

    required property var theme

    Layout.preferredWidth: 126
    Layout.preferredHeight: 28
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    text: "▁▂▃▄▅▆▇█▇▆▅▄"
    color: theme.primary
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 15
    font.bold: true

    Behavior on color {
        ColorAnimation {
            duration: 240
        }
    }

    Process {
        running: true
        command: [Quickshell.shellPath("scripts/cava.sh")]
        stdout: SplitParser {
            onRead: data => {
                const next = data.trim()
                if (next.length > 0)
                    root.text = next
            }
        }
    }
}
