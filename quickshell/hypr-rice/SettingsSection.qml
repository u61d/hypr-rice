import QtQuick
import QtQuick.Layouts

// A labeled group of settings (the "PALETTE" / "BEHAVIOR" style all-caps
// headers), generalized into one component instead of retyping the label
// + spacing per section. Anything passed as a child lands in the content
// column below the header.
ColumnLayout {
    id: root

    property string title: ""
    property string icon: ""
    default property alias content: contentColumn.data

    Layout.fillWidth: true
    Layout.topMargin: 4
    spacing: 10

    RowLayout {
        spacing: 6
        visible: root.title.length > 0

        Text {
            visible: root.icon.length > 0
            text: root.icon
            color: Theme.muted
            font.family: Fonts.icon
            font.pixelSize: 13
        }

        Text {
            text: root.title
            color: Theme.muted
            font.family: Fonts.sans
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }

    ColumnLayout {
        id: contentColumn
        Layout.fillWidth: true
        spacing: 10
    }
}
