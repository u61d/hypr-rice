import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Row {
    id: root
    required property var theme
    
    spacing: 3
    
    property var values: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    Repeater {
        model: 12
        Rectangle {
            width: 8
            height: Math.max(2, root.values[index] * 2.5)
            color: root.theme.primary
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            
            Behavior on height { 
                NumberAnimation { duration: 120; easing.type: Easing.OutSine } 
            }
            Behavior on color { ColorAnimation { duration: 240 } }
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
                    // Pad or truncate to 12 values
                    while (parts.length < 12) parts.push(0)
                    root.values = parts.slice(0, 12)
                }
            }
        }
    }
}