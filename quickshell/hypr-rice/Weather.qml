import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 200
    height: 100
    radius: 16
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.5)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

    property string temp: "--"
    property string conditionText: "Loading..."
    property string conditionIcon: "󰖐"

    function updateWeather() {
        if (!weatherProc.running) weatherProc.running = true
    }

    Process {
        id: weatherProc
        // wttr.in format: %t (temp), %C (condition text)
        command: ["sh", "-c", "curl -s 'wttr.in/?format=%t|%C'"]
        stdout: StdioCollector {
            id: weatherOutput
            onStreamFinished: {
                let parts = weatherOutput.text.trim().split('|')
                if (parts.length >= 2) {
                    root.temp = parts[0].replace("+", "")
                    root.conditionText = parts[1]

                    let c = parts[1].toLowerCase()
                    if (c.includes("clear") || c.includes("sunny")) root.conditionIcon = "󰖙"
                    else if (c.includes("cloud") || c.includes("overcast")) root.conditionIcon = "󰖐"
                    else if (c.includes("rain") || c.includes("drizzle")) root.conditionIcon = "󰖗"
                    else if (c.includes("snow") || c.includes("ice")) root.conditionIcon = "󰖘"
                    else if (c.includes("thunder") || c.includes("storm")) root.conditionIcon = "󰙾"
                    else root.conditionIcon = "󰖐"
                }
            }
        }
    }

    Timer {
        interval: 1800000 // 30 mins
        running: true
        repeat: true
        onTriggered: updateWeather()
    }

    Component.onCompleted: updateWeather()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Text {
            text: root.conditionIcon
            color: Theme.primary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 42
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.temp
                color: Theme.text
                font.family: "Inter"
                font.pixelSize: 24
                font.bold: true
            }

            Text {
                text: root.conditionText
                color: Theme.muted
                font.family: "Inter"
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
