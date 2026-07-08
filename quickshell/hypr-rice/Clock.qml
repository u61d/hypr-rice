import QtQuick
import QtQuick.Layouts
import Quickshell
Text {
    id: root
    Layout.preferredWidth: 132
    Layout.preferredHeight: 28
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: Theme.text
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 14
    font.bold: true
    text: Qt.formatDateTime(clock.date, "HH:mm   ddd dd MMM")
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "hypr-rice", "toggleCalendar"])
    }
}