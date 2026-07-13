pragma Singleton
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

// Small persisted store for shell-level preferences — the things the
// settings panel toggles that should actually survive a restart/relogin.
//
// Lives at ~/.config/hypr-rice/settings.json, deliberately OUTSIDE
// ~/.config/quickshell/, because install.sh backs up and replaces the
// whole quickshell/ folder on every reinstall. Keeping this file in its
// own directory means re-running install.sh never wipes your preferences.
//
// Usage from any file in this directory (no import needed, same as
// Theme/Fonts):
//   checked: Settings.options.hyprlandAnimations
//   onToggled: (v) => Settings.options.hyprlandAnimations = v
Singleton {
    id: root

    readonly property string configDir: {
        const loc = StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0].toString();
        const plain = loc.startsWith("file://") ? loc.slice(7) : loc;
        return plain + "/hypr-rice";
    }
    readonly property string filePath: root.configDir + "/settings.json"
    property alias options: adapter
    property bool ready: false

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.configDir])

    // Debounce writes so flipping several toggles quickly doesn't hammer disk.
    Timer {
        id: writeTimer
        interval: 150
        repeat: false
        onTriggered: fileView.writeAdapter()
    }

    FileView {
        id: fileView
        path: root.filePath
        watchChanges: true
        onLoaded: root.ready = true
        onLoadFailed: function(error) {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }
        onAdapterUpdated: writeTimer.restart()

        JsonAdapter {
            id: adapter

            // Live-toggled via `hyprctl keyword animations:enabled`, which
            // Hyprland forgets the instant it re-reads hyprland.lua (login,
            // `hyprctl reload`, etc). We re-assert this value ourselves once
            // the shell has actually finished reading the saved preference.
            property bool hyprlandAnimations: true
        }
    }

    onReadyChanged: {
        if (root.ready)
            Quickshell.execDetached(["hyprctl", "keyword", "animations:enabled", root.options.hyprlandAnimations ? "1" : "0"]);
    }
}
