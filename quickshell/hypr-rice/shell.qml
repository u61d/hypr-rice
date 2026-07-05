import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    Theme {
        id: theme
    }

    HyprState {
        id: hypr
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            required property ShellScreen modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 8
                left: 12
                right: 12
            }

            exclusiveZone: 48
            aboveWindows: true
            color: "transparent"
            implicitHeight: 38
            WlrLayershell.namespace: "hypr-rice-bar"

            Bar {
                anchors.fill: parent
                theme: theme
                hypr: hypr
                panelWindow: barWindow
                screenName: modelData.name
            }
        }
    }

    IpcHandler {
        target: "hypr-rice"

        function reloadTheme() {
            Quickshell.reload(false)
        }
    }
}
