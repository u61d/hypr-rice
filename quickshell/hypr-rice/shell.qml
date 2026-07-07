import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    Theme { id: theme }
    HyprState { id: hypr }

    QtObject {
        id: globalState
        property bool dashboardVisible: false
        property bool clipboardVisible: false
        property bool powerMenuVisible: false
        property bool notificationCenterVisible: false
        property bool dndEnabled: false
        property bool calendarVisible: false
    }

    QtObject {
        id: osdBridge
        property string mode: "volume"
        property int value: 0
        property int tick: 0
    }

    QtObject {
        id: screenshotBridge
        property string path: ""
        property int tick: 0
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

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            color: "transparent"
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "notifications"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: null

            NotificationDaemon { theme: theme }
        }

        PanelWindow {
            id: dashboardWindow
            required property ShellScreen modelData
            screen: modelData
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            color: "transparent"
            aboveWindows: true
            visible: globalState.dashboardVisible
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "dashboard"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            
            Dashboard { theme: theme; win: dashboardWindow }
        }

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "desktop-widget"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: null

            DesktopWidget {
                anchors.fill: parent
                theme: theme
            }
        }

        PanelWindow {
            id: osdWindow
            required property ShellScreen modelData
            screen: modelData
            color: "transparent"
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "osd"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: null
            visible: false

            OSD {
                theme: theme
                win: osdWindow
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 100
            }
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
        function showOsd(mode: string, val: string): void {
            osdBridge.mode = mode
            osdBridge.value = parseInt(val)
            osdBridge.tick++
        }
        function showScreenshot(path: string): void {
            screenshotBridge.path = path
            screenshotBridge.tick++
        }
    }
}
