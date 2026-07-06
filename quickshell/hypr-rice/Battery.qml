import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Rectangle {
    id: root
    required property var theme

    // UPower.displayDevice provides the aggregate system battery
    property var bat: UPower.displayDevice
    
    // Only show if a battery actually exists (laptops)
    visible: bat && bat.isPresent && bat.state !== UPowerDeviceState.Unknown
    
    Layout.preferredHeight: 28
    implicitWidth: visible ? Math.max(100, row.implicitWidth + 24) : 0
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.18) : "transparent"
    scale: mouse.containsMouse ? 1.04 : 1

    Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            // Icon logic based on state and percentage
            text: {
                if (!bat) return "󰂎"
                if (bat.state === UPowerDeviceState.Charging) return "󰂄"
                const p = bat.percentage
                if (p > 90) return "󰁹"
                if (p > 80) return "󰂂"
                if (p > 70) return "󰂁"
                if (p > 60) return "󰂀"
                if (p > 50) return "󰁿"
                if (p > 40) return "󰁾"
                if (p > 30) return "󰁽"
                if (p > 20) return "󰁼"
                if (p > 10) return "󰁻"
                return "󰂎"
            }
            color: bat && bat.percentage < 20 && bat.state !== UPowerDeviceState.Charging ? root.theme.red : root.theme.green
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            font.bold: true
        }

        Text {
            text: bat ? Math.round(bat.percentage) + "%" : "0%"
            color: bat && bat.percentage < 20 && bat.state !== UPowerDeviceState.Charging ? root.theme.red : root.theme.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
