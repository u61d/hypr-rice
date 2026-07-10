import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Rectangle {
    id: root

    // UPower.displayDevice provides the aggregate system battery
    property var bat: UPower.displayDevice
    
    // Only show if a battery actually exists (laptops)
    visible: bat && bat.isPresent && bat.state !== UPowerDeviceState.Unknown
    
    Layout.preferredHeight: 28
    implicitWidth: visible ? Math.max(100, row.implicitWidth + 24) : 0
    radius: 11
    
    color: mouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : "transparent"
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
                if (!bat) return "\ue1a6" // battery_unknown
                if (bat.state === UPowerDeviceState.Charging) return "\ue1a3" // battery_charging_full
                const p = bat.percentage
                if (p > 90) return "\ue1a5" // battery_full
                if (p > 80) return "\uf0a1" // battery_6_bar
                if (p > 70) return "\uf0a0" // battery_5_bar
                if (p > 60) return "\uf09f" // battery_4_bar
                if (p > 50) return "\uf09f" // battery_4_bar
                if (p > 40) return "\uf09e" // battery_3_bar
                if (p > 30) return "\uf09d" // battery_2_bar
                if (p > 20) return "\uf09c" // battery_1_bar
                if (p > 10) return "\uebdc" // battery_0_bar
                return "\ue19c" // battery_alert
            }
            color: bat && bat.percentage < 20 && bat.state !== UPowerDeviceState.Charging ? Theme.red : Theme.green
            font.family: Fonts.icon
            font.pixelSize: 18
        }

        Text {
            text: bat ? Math.round(bat.percentage) + "%" : "0%"
            color: bat && bat.percentage < 20 && bat.state !== UPowerDeviceState.Charging ? Theme.red : Theme.text
            font.family: Fonts.sans
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
