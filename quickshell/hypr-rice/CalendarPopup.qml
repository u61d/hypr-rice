import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData
    color: "transparent"
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "calendar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.calendarVisible

    property int currentMonthOffset: 0


    SystemClock { id: sysClock }

    MouseArea {
        anchors.fill: parent
        onClicked: globalState.calendarVisible = false
    }

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay();
    }

    function buildMonthDays() {
        const d = new Date()
        const targetDate = new Date(d.getFullYear(), d.getMonth() + root.currentMonthOffset, 1)
        const year = targetDate.getFullYear()
        const month = targetDate.getMonth()
        const daysInMonth = getDaysInMonth(year, month)
        const firstDay = getFirstDayOfMonth(year, month)
        const days = []

        for (let i = 0; i < 42; i++) {
            const dayNum = i - firstDay + 1
            if (i < firstDay || dayNum > daysInMonth) {
                days.push({ dayText: "", isToday: false })
            } else {
                const isToday = (root.currentMonthOffset === 0 && dayNum === sysClock.date.getDate())
                days.push({ dayText: dayNum.toString(), isToday: isToday })
            }
        }
        return days
    }

    Rectangle {
        width: 320
        height: 380
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        radius: 16
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.95)
        border.width: 1
        border.color: Theme.primary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                MouseArea {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: parent.containsMouse ? Theme.primary : Theme.text
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    onClicked: root.currentMonthOffset--
                }

                Text {
                    property var displayedDate: {
                        const d = new Date()
                        d.setMonth(d.getMonth() + root.currentMonthOffset)
                        return d
                    }
                    text: Qt.formatDateTime(displayedDate, "MMMM yyyy")
                    color: Theme.primary
                    font.family: "Inter"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: parent.containsMouse ? Theme.primary : Theme.text
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    onClicked: root.currentMonthOffset++
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.surfaceHigh
            }

            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    delegate: Text {
                        required property string modelData
                        text: modelData
                        color: Theme.muted
                        font.family: "Inter"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            GridLayout {
                columns: 7
                rowSpacing: 8
                columnSpacing: 8
                Layout.fillWidth: true
                Layout.fillHeight: true

                Repeater {
                    model: root.buildMonthDays()
                    delegate: Rectangle {
                        required property string dayText
                        required property bool isToday
                        Layout.fillWidth: true
                        Layout.preferredHeight: width
                        radius: width / 2
                        color: isToday ? Theme.primary
                            : (dayMouse.containsMouse && dayText !== "" ? Theme.surfaceHigh : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: parent.dayText
                            color: parent.isToday ? Theme.base : Theme.text
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.bold: parent.isToday
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: parent.dayText !== ""
                            cursorShape: parent.dayText !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }
        }
    }
}
