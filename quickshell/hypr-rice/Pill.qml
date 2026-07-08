import QtQuick
Rectangle {
    id: root
    implicitWidth: childrenRect.width + 18
    implicitHeight: 38
    radius: 16
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.74)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
    Behavior on color { ColorAnimation { duration: 260; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 260; easing.type: Easing.OutCubic } }
}