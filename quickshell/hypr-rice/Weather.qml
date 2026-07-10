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
    property string conditionIcon: "\uf15c" // wb_cloudy

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
                    if (c.includes("clear") || c.includes("sunny")) root.conditionIcon = "\ue81a" // sunny
                    else if (c.includes("cloud") || c.includes("overcast")) root.conditionIcon = "\uf15c" // wb_cloudy
                    else if (c.includes("rain") || c.includes("drizzle")) root.conditionIcon = "\uf176" // rainy
                    else if (c.includes("snow") || c.includes("ice")) root.conditionIcon = "\ueb3b" // ac_unit
                    else if (c.includes("thunder") || c.includes("storm")) root.conditionIcon = "\uebdb" // thunderstorm
                    else root.conditionIcon = "\uf15c" // wb_cloudy
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
            font.family: Fonts.icon
            font.pixelSize: 36
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.temp
                color: Theme.text
                font.family: Fonts.sans
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }

            Text {
                text: root.conditionText
                color: Theme.muted
                font.family: Fonts.sans
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
