import QtQuick
import QtQuick.Layouts

// The icon rail on the left of the settings panel: a logo chip, a column
// of icon buttons with a highlight that glides between them, and a small
// tooltip that names the page on hover (the rail itself stays icon-only —
// this just stops it from reading as an unlabeled icon dock).
ColumnLayout {
    id: root

    property var model: []
    property string currentPage: ""
    signal pageSelected(string id)

    readonly property int activeIndex: root.model.findIndex(function(p) {
        return p.id === root.currentPage;
    })
    readonly property Item activeItem: navRepeater.itemAt(root.activeIndex)

    Layout.preferredWidth: 72
    Layout.maximumWidth: 72
    Layout.fillHeight: true
    spacing: 0

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 16
        Layout.bottomMargin: 24

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 12
            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)

            Text {
                anchors.centerIn: parent
                text: "\ue8b8" // settings gear
                color: Theme.primary
                font.family: Fonts.icon
                font.pixelSize: 20
            }
        }
    }

    // Sidebar nav with a shared highlight that glides between items
    Item {
        id: navWrap

        Layout.fillWidth: true
        Layout.preferredHeight: navList.implicitHeight

        Rectangle {
            id: navIndicator

            radius: 14
            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
            border.width: 1
            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.32)
            visible: root.activeItem !== null
            x: root.activeItem ? root.activeItem.x : 0
            y: root.activeItem ? root.activeItem.y : 0
            width: root.activeItem ? root.activeItem.width : 0
            height: root.activeItem ? root.activeItem.height : 0

            Behavior on y {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutExpo
                }
            }
        }

        ColumnLayout {
            id: navList

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            Repeater {
                id: navRepeater

                model: root.model

                Rectangle {
                    id: navItem

                    readonly property bool active: root.currentPage === modelData.id

                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignHCenter
                    radius: 14
                    color: (navMouse.containsMouse && !active) ? Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.35) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: navItem.active ? Theme.primary : Theme.muted
                        font.family: Fonts.icon
                        font.pixelSize: 22
                    }

                    MouseArea {
                        id: navMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pageSelected(modelData.id)
                    }

                    // Hover tooltip naming the page
                    Rectangle {
                        opacity: navMouse.containsMouse ? 1 : 0
                        visible: opacity > 0
                        anchors.left: parent.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 8
                        color: Theme.mantle
                        border.width: 1
                        border.color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.6)
                        implicitWidth: tipLabel.implicitWidth + 16
                        implicitHeight: tipLabel.implicitHeight + 10
                        z: 10

                        Text {
                            id: tipLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 12
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }
                    }
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
