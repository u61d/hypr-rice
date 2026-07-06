import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

PanelWindow {
    id: root
    required property var theme
    required property ShellScreen modelData
    screen: modelData

    width: 320
    height: 380
    color: "transparent"
    anchors.top: parent.top
    anchors.topMargin: 50
    anchors.horizontalCenter: parent.horizontalCenter
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "calendar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: null
    visible: globalState.calendarVisible

    property int currentMonthOffset: 0

    SystemClock { id: sysClock }

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay();
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.95)
        border.width: 1
        border.color: theme.primary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                MouseArea {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: parent.containsMouse ? root.theme.primary : root.theme.text
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    hoverEnabled: true
                    onClicked: root.currentMonthOffset--
                }

                Text {
                    id: monthText
                    property var displayedDate: {
                        let d = new Date()
                        d.setMonth(d.getMonth() + root.currentMonthOffset)
                        return d
                    }
                    text: Qt.formatDateTime(displayedDate, "MMMM yyyy")
                    color: root.theme.primary
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
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: parent.containsMouse ? root.theme.primary : root.theme.text
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    hoverEnabled: true
                    onClicked: root.currentMonthOffset++
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: root.theme.surfaceHigh
            }

            // Days of week
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    Text {
                        text: modelData
                        color: root.theme.muted
                        font.family: "Inter"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Calendar Grid
            GridLayout {
                columns: 7
                rowSpacing: 8
                columnSpacing: 8
                Layout.fillWidth: true
                Layout.fillHeight: true

                Repeater {
                    id: daysRepeater
                    model: {
                        let d = new Date()
                        let curYear = d.getFullYear()
                        let curMonth = d.getMonth()
                        
                        let targetDate = new Date(curYear, curMonth + root.currentMonthOffset, 1)
                        let year = targetDate.getFullYear()
                        let month = targetDate.getMonth()
                        
                        let daysInMonth = getDaysInMonth(year, month)
                        let firstDay = getFirstDayOfMonth(year, month)
                        let totalSlots = 42 // 6 rows of 7 days
                        
                        let days = []
                        for (let i = 0; i < totalSlots; i++) {
                            let dayNum = i - firstDay + 1
                            if (i < firstDay || dayNum > daysInMonth) {
                                days.push({ text: "", isToday: false })
                            } else {
                                let isToday = (root.currentMonthOffset === 0 && dayNum === sysClock.date.getDate())
                                days.push({ text: dayNum.toString(), isToday: isToday })
                            }
                        }
                        return days
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: width
                        radius: width / 2
                        color: modelData.isToday ? root.theme.primary : (mouseArea.containsMouse && modelData.text !== "" ? root.theme.surfaceHigh : "transparent")
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.text
                            color: modelData.isToday ? root.theme.base : root.theme.text
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.bold: modelData.isToday
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: modelData.text !== ""
                            cursorShape: modelData.text !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }
        }
    }
}
