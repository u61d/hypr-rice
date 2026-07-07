import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var theme
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

    readonly property color cBase: root.theme ? root.theme.base : "#1e1e2e"
    readonly property color cPrimary: root.theme ? root.theme.primary : "#cba6f7"
    readonly property color cText: root.theme ? root.theme.text : "#cdd6f4"
    readonly property color cMuted: root.theme ? root.theme.muted : "#9399b2"
    readonly property color cSurfaceHigh: root.theme ? root.theme.surfaceHigh : "#45475a"

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
        color: Qt.rgba(root.cBase.r, root.cBase.g, root.cBase.b, 0.95)
        border.width: 1
        border.color: root.cPrimary

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
                        color: parent.containsMouse ? root.cPrimary : root.cText
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
                    color: root.cPrimary
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
                        color: parent.containsMouse ? root.cPrimary : root.cText
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    onClicked: root.currentMonthOffset++
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: root.cSurfaceHigh
            }

            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    delegate: Text {
                        required property string modelData
                        text: modelData
                        color: root.cMuted
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
                        color: isToday ? root.cPrimary
                            : (dayMouse.containsMouse && dayText !== "" ? root.cSurfaceHigh : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: parent.dayText
                            color: parent.isToday ? root.cBase : root.cText
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
