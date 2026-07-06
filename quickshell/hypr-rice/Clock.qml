import QtQuick
import QtQuick.Layouts
import Quickshell
Text {
    id: root
    required property var theme
    Layout.preferredWidth: 132
    Layout.preferredHeight: 28
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: theme.text
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 14
    font.bold: true
    text: Qt.formatDateTime(clock.date, "HH:mm   ddd dd MMM")
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}