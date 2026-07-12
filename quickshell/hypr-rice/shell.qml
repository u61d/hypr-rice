import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    QtObject {
        id: globalState
        property bool dashboardVisible: false
        property bool clipboardVisible: false
        property bool powerMenuVisible: false
        property bool notificationCenterVisible: false
        property bool dndEnabled: false
        property bool calendarVisible: false
        property bool networkMenuVisible: false
        property bool bluetoothMenuVisible: false
        property bool brightnessMenuVisible: false
        property bool settingsVisible: false

        // Opens exactly one popup at a time, closing any others so they
        // never overlap on screen.
        function openOnly(name) {
            clipboardVisible = name === "clipboard"
            powerMenuVisible = name === "power"
            notificationCenterVisible = name === "notifications"
            calendarVisible = name === "calendar"
            networkMenuVisible = name === "network"
            bluetoothMenuVisible = name === "bluetooth"
            brightnessMenuVisible = name === "brightness"
        }

        function toggleOnly(name, current) {
            if (current) {
                // it's already open, so this call is closing it
                if (name === "clipboard") clipboardVisible = false
                else if (name === "power") powerMenuVisible = false
                else if (name === "notifications") notificationCenterVisible = false
                else if (name === "calendar") calendarVisible = false
                else if (name === "network") networkMenuVisible = false
                else if (name === "bluetooth") bluetoothMenuVisible = false
                else if (name === "brightness") brightnessMenuVisible = false
            } else {
                openOnly(name)
            }
        }
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
                panelWindow: barWindow
                screenName: modelData.name
            }
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: notifWindow
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
            mask: Region { item: notifDaemon.maskItem }

            NotificationDaemon { id: notifDaemon }
        }
    }

    Variants {
        model: Quickshell.screens
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
            
            Dashboard { win: dashboardWindow; globalState: globalState }
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: settingsWindow
            required property ShellScreen modelData
            screen: modelData
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            color: "transparent"
            aboveWindows: true
            visible: globalState.settingsVisible
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "settings"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            SettingsPanel { win: settingsWindow; globalState: globalState }
        }
    }

    Variants {
        model: Quickshell.screens
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
            }
        }
    }

    Variants {
        model: Quickshell.screens
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
            mask: Region { item: osdItem }
            // visible is driven by OSD.qml's own close animation (root.mapped),
            // so the fade/scale-out actually plays before the window unmaps.

            OSD {
                id: osdItem
                win: osdWindow
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 100
            }
        }
    }

    Variants {
        model: Quickshell.screens
        ScreenCapture { modelData: modelData }
    }

    Variants {
        model: Quickshell.screens
        ClipboardHistory { modelData: modelData }
    }

    Variants {
        model: Quickshell.screens
        PowerMenu { modelData: modelData }
    }

    Variants {
        model: Quickshell.screens
        NotificationCenter { modelData: modelData }
    }

    Variants {
        model: Quickshell.screens
        CalendarPopup { modelData: modelData }
    }

    IpcHandler {
        target: "hypr-rice"
        function reloadTheme() {
            Quickshell.reload(false)
        }
        function toggleDashboard() {
            globalState.dashboardVisible = !globalState.dashboardVisible
        }
        function toggleSettings() {
            globalState.settingsVisible = !globalState.settingsVisible
        }
        function toggleClipboard() {
            globalState.toggleOnly("clipboard", globalState.clipboardVisible)
        }
        function togglePowerMenu() {
            globalState.toggleOnly("power", globalState.powerMenuVisible)
        }
        function toggleNotificationCenter() {
            globalState.toggleOnly("notifications", globalState.notificationCenterVisible)
        }
        function toggleDnd() {
            globalState.dndEnabled = !globalState.dndEnabled
        }
        function toggleCalendar() {
            globalState.toggleOnly("calendar", globalState.calendarVisible)
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
