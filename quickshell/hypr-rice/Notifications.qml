pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

NotificationServer {
    id: root
    keepOnReload: false

    // Backward-compat alias: rest of the shell reads Notifications.notifications
    readonly property alias notifications: root.trackedNotifications

    // Re-exposed as a plain "new notification" signal for Connections blocks
    signal notificationAdded(var notification)
    onNotification: (notification) => root.notificationAdded(notification)
}
