import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    required property var win
    required property var globalState
    property string currentPage: "appearance"
    readonly property var navModel: [
        {
            "id": "appearance",
            "label": "Appearance",
            "icon": "\ue40a",
            "page": "SettingsAppearancePage.qml"
        },
        {
            "id": "wallpaper",
            "label": "Wallpaper",
            "icon": "\ue3f4",
            "page": "SettingsWallpaperPage.qml"
        },
        {
            "id": "keybinds",
            "label": "Keybinds",
            "icon": "\ue312",
            "page": "SettingsKeybindsPage.qml"
        },
        {
            "id": "monitors",
            "label": "Monitors",
            "icon": "\ue30a",
            "page": "SettingsMonitorsPage.qml"
        },
        {
            "id": "about",
            "label": "About",
            "icon": "\ue88e",
            "page": "SettingsAboutPage.qml"
        }
    ]
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
            onClicked: {}
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            SettingsSidebar {
                model: root.navModel
                currentPage: root.currentPage
                onPageSelected: function(id) {
                    root.currentPage = id;
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

                    // === Page stack — one page alive at a time, not five ===
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Loader {
                            id: pageLoader

                            anchors.fill: parent

                            Component.onCompleted: {
                                source = root.currentPageMeta.page;
                            }

                            onLoaded: {
                                item.win = root.win;
                            }

                            Connections {
                                function onCurrentPageChanged() {
                                    switchAnim.complete();
                                    switchAnim.start();
                                }

                                target: root
                            }

                            SequentialAnimation {
                                id: switchAnim

                                NumberAnimation {
                                    target: pageLoader
                                    property: "opacity"
                                    from: 1
                                    to: 0
                                    duration: 90
                                    easing.type: Easing.OutCubic
                                }

                                PropertyAction {
                                    target: pageLoader
                                    property: "source"
                                    value: root.currentPageMeta.page
                                }

                                NumberAnimation {
                                    target: pageLoader
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 160
                                    easing.type: Easing.OutCubic
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
