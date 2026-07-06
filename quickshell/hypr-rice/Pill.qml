import QtQuick
Rectangle {
    id: root
    required property var theme
    implicitWidth: childrenRect.width + 18
    implicitHeight: 38
    radius: 16
    color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.74)
    border.width: 1
    border.color: Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.28)
    Behavior on color { ColorAnimation { duration: 260; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 260; easing.type: Easing.OutCubic } }
}