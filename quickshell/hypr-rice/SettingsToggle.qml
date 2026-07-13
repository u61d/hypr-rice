import QtQuick
import QtQuick.Layouts

// One settings row: optional icon chip, title + description, and an
// M3-style pill switch — the one thing every toggle in the panel should be
// built from now instead of a hand-copied rectangle-and-switch block per
// section. Click anywhere on the row to flip it, not just the switch.
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string description: ""
    property bool checked: false
    signal toggled(bool value)

    Layout.fillWidth: true
    Layout.preferredHeight: 60
    radius: 14
    color: mouseArea.containsMouse ? Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.4) : Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.6)
    border.width: 1
    border.color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)

    Behavior on color {
        ColorAnimation {
            duration: 160
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            visible: root.icon.length > 0
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 12
            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.14)

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: Theme.primary
                font.family: Fonts.icon
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.label
                color: Theme.text
                font.family: Fonts.sans
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                visible: root.description.length > 0
                text: root.description
                color: Theme.muted
                font.family: Fonts.sans
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // M3-style switch: pill track + border, thumb grows when on
        Rectangle {
            id: switchTrack

            Layout.preferredWidth: 46
            Layout.preferredHeight: 26
            radius: 13
            color: root.checked ? Theme.primary : "transparent"
            border.width: 2
            border.color: root.checked ? Theme.primary : Theme.muted

            Rectangle {
                id: switchThumb

                width: root.checked ? 18 : 14
                height: width
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                x: root.checked ? switchTrack.width - width - 4 : 4
                color: root.checked ? Theme.mantle : Theme.muted

                Behavior on x {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 180
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
