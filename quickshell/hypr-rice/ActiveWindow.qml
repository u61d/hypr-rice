import QtQuick
import QtQuick.Layouts
Item {
    id: root
    implicitWidth: Math.min(420, Math.max(90, title.implicitWidth + 20))
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: 28
    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Text {
        id: title
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        elide: Text.ElideRight
        text: HyprState.activeTitle.length > 0 ? HyprState.activeTitle : "Desktop"
        color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.90)
        font.family: Fonts.sans
        font.pixelSize: 13
        font.weight: Font.Medium
    }
}