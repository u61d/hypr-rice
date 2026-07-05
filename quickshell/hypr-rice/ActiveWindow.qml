import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    required property var hypr

    implicitWidth: Math.min(420, Math.max(90, title.implicitWidth + 20))
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: 28

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: title
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        elide: Text.ElideRight
        text: root.hypr.activeTitle.length > 0 ? root.hypr.activeTitle : "Desktop"
        color: Qt.rgba(root.theme.text.r, root.theme.text.g, root.theme.text.b, 0.78)
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.bold: true
    }
}
