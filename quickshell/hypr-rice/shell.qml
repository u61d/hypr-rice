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
        property bool clipboardVisible: false
        property bool powerMenuVisible: false
        property bool notificationCenterVisible: false
        property bool dndEnabled: false
        property bool calendarVisible: false
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

        // OSD Overlay (Volume/Brightness)
        PanelWindow {
            id: osdWindow
            required property ShellScreen modelData
            screen: modelData
            color: "transparent"
            anchors.bottom: true
            anchors.bottomMargin: 100
            anchors.horizontalCenter: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "osd"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: null
            visible: false

            OSD { theme: theme; win: osdWindow }
        }

        ScreenCapture { theme: theme; modelData: modelData }
        ClipboardHistory { theme: theme; modelData: modelData }
        PowerMenu { theme: theme; modelData: modelData }
        NotificationCenter { theme: theme; modelData: modelData }
        CalendarPopup { theme: theme; modelData: modelData }
    }

    IpcHandler {
        target: "hypr-rice"
        function reloadTheme() {
            Quickshell.reload(false)
        }
        function toggleDashboard() {
            globalState.dashboardVisible = !globalState.dashboardVisible
        }
        function toggleClipboard() {
            globalState.clipboardVisible = !globalState.clipboardVisible
        }
        function togglePowerMenu() {
            globalState.powerMenuVisible = !globalState.powerMenuVisible
        }
        function toggleNotificationCenter() {
            globalState.notificationCenterVisible = !globalState.notificationCenterVisible
        }
        function toggleDnd() {
            globalState.dndEnabled = !globalState.dndEnabled
        }
        function toggleCalendar() {
            globalState.calendarVisible = !globalState.calendarVisible
        }
        function showOsd(mode, val) {
            // Signal the OSD window if it exists
            if (typeof osdWindow !== "undefined") {
                osdWindow.children[0].showOsd(mode, parseInt(val))
            }
        }
    }
}