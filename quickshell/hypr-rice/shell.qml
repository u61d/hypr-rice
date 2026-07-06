import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    Theme { id: theme }
    HyprState { id: hypr }

    // Global state
    QtObject {
        id: globalState
        property bool dashboardVisible: false
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
            exclusiveZone: 46 
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

        // Notification Daemon (Overlay)
        PanelWindow {
            required property ShellScreen modelData
            screen: modelData
            anchors.fill: parent
            color: "transparent"
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "notifications"
            // Pass clicks through so it doesn't block the screen
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: null

            NotificationDaemon { theme: theme }
        }

        // Dashboard Launcher (Overlay, toggleable)
        PanelWindow {
            id: dashboardWindow
            required property ShellScreen modelData
            screen: modelData
            anchors.fill: parent
            color: "transparent"
            aboveWindows: true
            visible: globalState.dashboardVisible
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "dashboard"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            
            Dashboard { theme: theme; win: dashboardWindow }
        }

        // Desktop Widget (Background layer)
        PanelWindow {
            required property ShellScreen modelData
            screen: modelData
            anchors.fill: parent
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "desktop-widget"
            // Pass clicks to wallpaper/desktop
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: null

            DesktopWidget { theme: theme }
        }
    }

    IpcHandler {
        target: "hypr-rice"
        function reloadTheme() {
            Quickshell.reload(false)
        }
        function toggleDashboard() {
            globalState.dashboardVisible = !globalState.dashboardVisible
        }
    }
}