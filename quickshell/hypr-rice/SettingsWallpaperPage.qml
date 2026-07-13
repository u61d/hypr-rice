import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Owns its own GridView (which is Flickable itself), so unlike the simple
// pages this doesn't use the shared SettingsPage scroll wrapper — nesting
// two independently-scrolling Flickables gets fights over wheel/gesture
// input for no benefit here.
Item {
    id: page

    property var win: null

    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "From ~/Pictures/Wallpapers — click one to set it and re-theme the whole rice with matugen."
                color: Theme.muted
                font.family: Fonts.sans
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text: wallpaperModel.count + " found"
                color: Theme.muted
                font.family: Fonts.sans
                font.pixelSize: 12
            }
        }

        GridView {
            id: wallGrid

            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 172
            cellHeight: 114
            clip: true
            visible: wallpaperModel.count > 0

            model: ScriptModel {
                id: wallpaperModel

                values: wallpaperListProc.paths
            }

            delegate: Item {
                width: wallGrid.cellWidth
                height: wallGrid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 14
                    clip: true
                    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.5)
                    border.width: wallMouse.containsMouse ? 2 : 0
                    border.color: Theme.primary
                    scale: wallMouse.pressed ? 0.95 : (wallMouse.containsMouse ? 1.04 : 1)

                    Image {
                        anchors.fill: parent
                        source: "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    MouseArea {
                        id: wallMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["bash", "-c", "exec \"$HOME/.config/hypr/scripts/wallpaper.sh\" \"$1\"", "wallpaper.sh", modelData])
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }
        }

        Text {
            visible: wallpaperModel.count === 0
            text: "No wallpapers found. Drop some images into ~/Pictures/Wallpapers."
            color: Theme.muted
            font.family: Fonts.sans
            font.pixelSize: 13
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 40
        }
    }

    Process {
        id: wallpaperListProc

        property var paths: []

        // Loader only instantiates this page while it's the active tab, so
        // the old `root.currentPage === "wallpaper"` guard is gone — just
        // don't bother re-scanning while the whole panel is hidden.
        running: page.win ? page.win.visible : true
        onRunningChanged: function() {
            if (running)
                paths = [];
        }
        command: ["bash", "-c", "find \"$HOME/Pictures/Wallpapers\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort"]

        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim().length > 0)
                    wallpaperListProc.paths = wallpaperListProc.paths.concat([data.trim()]);
            }
        }
    }
}
