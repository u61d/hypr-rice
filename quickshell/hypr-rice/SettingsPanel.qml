import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    required property var win
    required property var globalState
    property string currentPage: "appearance"
    readonly property var navModel: [{
        "id": "appearance",
        "label": "Appearance",
        "icon": "\ue40a"
    }, {
        "id": "wallpaper",
        "label": "Wallpaper",
        "icon": "\ue3f4"
    }, {
        "id": "keybinds",
        "label": "Keybinds",
        "icon": "\ue312"
    }, {
        "id": "monitors",
        "label": "Monitors",
        "icon": "\ue30a"
    }, {
        "id": "about",
        "label": "About",
        "icon": "\ue88e"
    }]
    readonly property var currentPageMeta: navModel.find(function(p) {
        return p.id === currentPage;
    }) || navModel[0]

    anchors.fill: parent
    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.72)
    opacity: win.visible ? 1 : 0
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            root.globalState.settingsVisible = false;
            event.accepted = true;
        }
    }

    // Click background to dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: root.globalState.settingsVisible = false
    }

    Connections {
        function onVisibleChanged() {
            if (win.visible)
                root.forceActiveFocus();

        }

        target: win
    }

    // === Central Card ===
    Rectangle {
        id: mainCard

        anchors.centerIn: parent
        width: 920
        height: 640
        radius: 26
        clip: true
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
        scale: win.visible ? 1 : 0.88
        opacity: win.visible ? 1 : 0

        // Swallow clicks so they don't fall through to the background dismiss area
        MouseArea {
            anchors.fill: parent
            onClicked: {
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // === Sidebar ===
            ColumnLayout {
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

                        // settings gear
                        Text {
                            anchors.centerIn: parent
                            text: "\ue8b8"
                            color: Theme.primary
                            font.family: Fonts.icon
                            font.pixelSize: 20
                        }

                    }

                }

                // Sidebar nav with a shared highlight that glides between items
                Item {
                    id: navWrap

                    readonly property int activeIndex: root.navModel.findIndex(function(p) {
                        return p.id === root.currentPage;
                    })
                    readonly property Item activeItem: navRepeater.itemAt(activeIndex)

                    Layout.fillWidth: true
                    Layout.preferredHeight: navList.implicitHeight

                    Rectangle {
                        id: navIndicator

                        radius: 14
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.32)
                        visible: navWrap.activeItem !== null
                        x: navWrap.activeItem ? navWrap.activeItem.x : 0
                        y: navWrap.activeItem ? navWrap.activeItem.y : 0
                        width: navWrap.activeItem ? navWrap.activeItem.width : 0
                        height: navWrap.activeItem ? navWrap.activeItem.height : 0

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

                            model: root.navModel

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
                                    onClicked: root.currentPage = modelData.id
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

            // === Content surface — visually separated from the sidebar ===
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 20
                color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.55)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 26
                    spacing: 16

                    RowLayout {
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            radius: 15
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)

                            Text {
                                anchors.centerIn: parent
                                text: root.currentPageMeta.icon
                                color: Theme.primary
                                font.family: Fonts.icon
                                font.pixelSize: 21
                            }

                        }

                        Text {
                            text: root.currentPageMeta.label
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 22
                            font.weight: Font.Bold
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)
                    }

                    // === Page stack ===
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // ---- Appearance ----
                        Item {
                            anchors.fill: parent
                            visible: root.currentPage === "appearance"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                                Text {
                                    text: "Colors are generated automatically from your wallpaper via matugen — pick a new one in the Wallpaper tab to re-theme everything."
                                    color: Theme.muted
                                    font.family: Fonts.sans
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "PALETTE"
                                    color: Theme.muted
                                    font.family: Fonts.sans
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    Layout.topMargin: 4
                                }

                                GridLayout {
                                    columns: 4
                                    columnSpacing: 12
                                    rowSpacing: 14
                                    Layout.fillWidth: true

                                    Repeater {
                                        model: [{
                                            "name": "base",
                                            "c": Theme.base
                                        }, {
                                            "name": "mantle",
                                            "c": Theme.mantle
                                        }, {
                                            "name": "surface",
                                            "c": Theme.surface
                                        }, {
                                            "name": "surfaceHigh",
                                            "c": Theme.surfaceHigh
                                        }, {
                                            "name": "text",
                                            "c": Theme.text
                                        }, {
                                            "name": "muted",
                                            "c": Theme.muted
                                        }, {
                                            "name": "primary",
                                            "c": Theme.primary
                                        }, {
                                            "name": "secondary",
                                            "c": Theme.secondary
                                        }, {
                                            "name": "tertiary",
                                            "c": Theme.tertiary
                                        }, {
                                            "name": "green",
                                            "c": Theme.green
                                        }, {
                                            "name": "yellow",
                                            "c": Theme.yellow
                                        }, {
                                            "name": "red",
                                            "c": Theme.red
                                        }]

                                        ColumnLayout {
                                            spacing: 6

                                            Rectangle {
                                                Layout.preferredWidth: 150
                                                Layout.preferredHeight: 48
                                                radius: 12
                                                color: modelData.c
                                                border.width: 1
                                                border.color: Qt.rgba(1, 1, 1, 0.08)
                                            }

                                            Text {
                                                text: modelData.name
                                                color: Theme.text
                                                font.family: Fonts.sans
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                text: {
                                                    const c = modelData.c;
                                                    const hex = function hex(v) {
                                                        return Math.round(v * 255).toString(16).padStart(2, "0");
                                                    };
                                                    return "#" + hex(c.r) + hex(c.g) + hex(c.b);
                                                }
                                                color: Theme.muted
                                                font.family: Fonts.sans
                                                font.pixelSize: 11
                                            }

                                        }

                                    }

                                }

                                Text {
                                    text: "BEHAVIOR"
                                    color: Theme.muted
                                    font.family: Fonts.sans
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    Layout.topMargin: 8
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 14
                                    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.6)
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                text: "Hyprland animations"
                                                color: Theme.text
                                                font.family: Fonts.sans
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                text: "Live toggle via hyprctl — resets on restart, doesn't touch your config file."
                                                color: Theme.muted
                                                font.family: Fonts.sans
                                                font.pixelSize: 11
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }

                                        }

                                        // M3-style switch: pill track + border, thumb grows when on
                                        Rectangle {
                                            id: animSwitch

                                            property bool on: true

                                            Layout.preferredWidth: 46
                                            Layout.preferredHeight: 26
                                            radius: 13
                                            color: on ? Theme.primary : "transparent"
                                            border.width: 2
                                            border.color: on ? Theme.primary : Theme.muted

                                            Rectangle {
                                                id: switchThumb

                                                width: animSwitch.on ? 18 : 14
                                                height: width
                                                radius: width / 2
                                                anchors.verticalCenter: parent.verticalCenter
                                                x: animSwitch.on ? animSwitch.width - width - 4 : 4
                                                color: animSwitch.on ? Theme.mantle : Theme.muted

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

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    animSwitch.on = !animSwitch.on;
                                                    Quickshell.execDetached(["hyprctl", "keyword", "animations:enabled", animSwitch.on ? "1" : "0"]);
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

                                }

                                Item {
                                    Layout.fillHeight: true
                                }

                            }

                        }

                        // ---- Wallpaper ----
                        Item {
                            anchors.fill: parent
                            visible: root.currentPage === "wallpaper"

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

                                running: root.currentPage === "wallpaper" && root.win.visible
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

                        // ---- Keybinds ----
                        Item {
                            anchors.fill: parent
                            visible: root.currentPage === "keybinds"

                            Flickable {
                                anchors.fill: parent
                                clip: true
                                contentWidth: width
                                contentHeight: keybindsFlow.implicitHeight

                                ColumnLayout {
                                    id: keybindsFlow

                                    width: parent.width
                                    spacing: 18

                                    Repeater {
                                        model: [{
                                            "section": "Apps & windows",
                                            "items": [{
                                                "keys": ["Super", "Return"],
                                                "desc": "Open terminal"
                                            }, {
                                                "keys": ["Super", "E"],
                                                "desc": "Open file manager"
                                            }, {
                                                "keys": ["Super", "Space"],
                                                "desc": "Toggle app launcher"
                                            }, {
                                                "keys": ["Super", "I"],
                                                "desc": "Open this settings panel"
                                            }, {
                                                "keys": ["Super", "Q"],
                                                "desc": "Close focused window"
                                            }, {
                                                "keys": ["Super", "Shift", "Q"],
                                                "desc": "Exit Hyprland"
                                            }, {
                                                "keys": ["Super", "Shift", "V"],
                                                "desc": "Toggle floating"
                                            }, {
                                                "keys": ["Super", "P"],
                                                "desc": "Toggle pseudotile"
                                            }, {
                                                "keys": ["Super", "J"],
                                                "desc": "Toggle split direction"
                                            }, {
                                                "keys": ["Super", "F"],
                                                "desc": "Toggle fullscreen"
                                            }, {
                                                "keys": ["Super", "L"],
                                                "desc": "Lock screen"
                                            }]
                                        }, {
                                            "section": "Workspaces & focus",
                                            "items": [{
                                                "keys": ["Super", "\u2190/\u2192/\u2191/\u2193"],
                                                "desc": "Focus window in direction"
                                            }, {
                                                "keys": ["Super", "1-0"],
                                                "desc": "Switch to workspace"
                                            }, {
                                                "keys": ["Super", "Shift", "1-0"],
                                                "desc": "Move window to workspace"
                                            }, {
                                                "keys": ["Super", "S"],
                                                "desc": "Toggle special workspace"
                                            }, {
                                                "keys": ["Super", "Ctrl", "S"],
                                                "desc": "Move window to special workspace"
                                            }, {
                                                "keys": ["Super", "Tab"],
                                                "desc": "Toggle workspace overview"
                                            }]
                                        }, {
                                            "section": "Bar & menus",
                                            "items": [{
                                                "keys": ["Super", "V"],
                                                "desc": "Clipboard history"
                                            }, {
                                                "keys": ["Super", "N"],
                                                "desc": "Notification center"
                                            }]
                                        }, {
                                            "section": "Screenshots & media",
                                            "items": [{
                                                "keys": ["Print"],
                                                "desc": "Screenshot (area)"
                                            }, {
                                                "keys": ["Super", "Print"],
                                                "desc": "Screenshot (full)"
                                            }, {
                                                "keys": ["Super", "Shift", "S"],
                                                "desc": "Screenshot (area)"
                                            }, {
                                                "keys": ["Super", "Shift", "R"],
                                                "desc": "Screen recording"
                                            }, {
                                                "keys": ["Super", "Shift", "C"],
                                                "desc": "Color picker"
                                            }, {
                                                "keys": ["Super", "W"],
                                                "desc": "Random wallpaper + re-theme"
                                            }, {
                                                "keys": ["Super", "G"],
                                                "desc": "Toggle gamemode"
                                            }]
                                        }, {
                                            "section": "Media keys",
                                            "items": [{
                                                "keys": ["Vol +/-"],
                                                "desc": "Adjust volume"
                                            }, {
                                                "keys": ["Mute"],
                                                "desc": "Mute audio"
                                            }, {
                                                "keys": ["Bright +/-"],
                                                "desc": "Adjust screen brightness"
                                            }]
                                        }, {
                                            "section": "Mouse",
                                            "items": [{
                                                "keys": ["Super", "L-drag"],
                                                "desc": "Move window"
                                            }, {
                                                "keys": ["Super", "R-drag"],
                                                "desc": "Resize window"
                                            }]
                                        }]

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: modelData.section
                                                color: Theme.primary
                                                font.family: Fonts.sans
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                            }

                                            Repeater {
                                                model: modelData.items

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 12

                                                    RowLayout {
                                                        spacing: 4
                                                        Layout.preferredWidth: 190
                                                        Layout.alignment: Qt.AlignVCenter

                                                        Repeater {
                                                            model: modelData.keys

                                                            // === 3D keycap widget ===
                                                            Rectangle {
                                                                id: keyCap

                                                                readonly property real bw: 1
                                                                readonly property real extraBottom: 2

                                                                implicitWidth: keyFace.implicitWidth + bw * 2
                                                                implicitHeight: keyFace.implicitHeight + bw * 2 + extraBottom
                                                                radius: 7
                                                                color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.95)

                                                                Rectangle {
                                                                    id: keyFace

                                                                    implicitWidth: keyLabel.implicitWidth + 14
                                                                    implicitHeight: keyLabel.implicitHeight + 6
                                                                    radius: 6
                                                                    color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.95)

                                                                    anchors {
                                                                        fill: parent
                                                                        topMargin: keyCap.bw
                                                                        leftMargin: keyCap.bw
                                                                        rightMargin: keyCap.bw
                                                                        bottomMargin: keyCap.bw + keyCap.extraBottom
                                                                    }

                                                                    Text {
                                                                        id: keyLabel

                                                                        anchors.centerIn: parent
                                                                        text: modelData
                                                                        color: Theme.text
                                                                        font.family: Fonts.sans
                                                                        font.pixelSize: 11
                                                                        font.weight: Font.DemiBold
                                                                    }

                                                                }

                                                            }

                                                        }

                                                    }

                                                    Text {
                                                        text: modelData.desc
                                                        color: Theme.muted
                                                        font.family: Fonts.sans
                                                        font.pixelSize: 12
                                                        Layout.fillWidth: true
                                                    }

                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                        // ---- Monitors ----
                        Item {
                            anchors.fill: parent
                            visible: root.currentPage === "monitors"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 14

                                Text {
                                    text: "Live info from Quickshell. To rearrange or add custom modelines, edit the monitor block in hyprland.lua."
                                    color: Theme.muted
                                    font.family: Fonts.sans
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Repeater {
                                        model: Quickshell.screens

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 76
                                            radius: 14
                                            color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.6)
                                            border.width: 1
                                            border.color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 14

                                                Rectangle {
                                                    Layout.preferredWidth: 48
                                                    Layout.preferredHeight: 48
                                                    radius: 12
                                                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.14)

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "\ue30a" // desktop_windows
                                                        color: Theme.primary
                                                        font.family: Fonts.icon
                                                        font.pixelSize: 22
                                                    }

                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.name
                                                        color: Theme.text
                                                        font.family: Fonts.sans
                                                        font.pixelSize: 15
                                                        font.weight: Font.DemiBold
                                                    }

                                                    Text {
                                                        text: modelData.width + "\u00d7" + modelData.height + " \u00b7 scale " + (modelData.devicePixelRatio || 1).toFixed(2) + " \u00b7 position " + modelData.x + "," + modelData.y
                                                        color: Theme.muted
                                                        font.family: Fonts.sans
                                                        font.pixelSize: 12
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

                        }

                        // ---- About ----
                        Item {
                            anchors.fill: parent
                            visible: root.currentPage === "about"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 12

                                Text {
                                    text: "Built with Hyprland, Quickshell, and a matugen-driven color pipeline that re-themes the bar, terminal, and lock screen from your wallpaper."
                                    color: Theme.muted
                                    font.family: Fonts.sans
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "github.com/u61d/hypr-rice"
                                    color: Theme.secondary
                                    font.family: Fonts.sans
                                    font.pixelSize: 13
                                }

                                Item {
                                    Layout.fillHeight: true
                                }

                            }

                        }

                    }

                }

            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }

    }

}
