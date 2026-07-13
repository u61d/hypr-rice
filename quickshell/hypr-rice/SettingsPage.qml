import QtQuick
import QtQuick.Layouts

// Shared scroll wrapper for settings pages that are just a vertical stack
// of sections (Appearance, Monitors, About). Pages that own their own
// scroll region — Wallpaper's grid, Keybinds' long list — skip this and
// declare their own root Item/Flickable instead.
//
// `win` is assigned by SettingsPanel's Loader after load; pages that don't
// need it (most of them) can just ignore it.
Flickable {
    id: root

    property var win: null
    default property alias content: contentColumn.data

    anchors.fill: parent
    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight + 24
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: contentColumn
        width: root.width
        spacing: 16
    }
}
