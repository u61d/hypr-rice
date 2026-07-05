import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var workspaces: []
    property int activeWorkspace: 1
    property string activeTitle: ""
    property string activeClass: ""

    function refresh() {
        if (!snapshot.running)
            snapshot.running = true
    }

    function dispatch(command) {
        Quickshell.execDetached(["hyprctl", "dispatch"].concat(command.split(" ")))
        refreshDebounce.restart()
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        id: refreshDebounce
        interval: 120
        repeat: false
        onTriggered: root.refresh()
    }

    Process {
        id: snapshot
        command: ["bash", "-lc", "hyprctl -j workspaces; printf '\\n---HYPR-RICE---\\n'; hyprctl -j activeworkspace; printf '\\n---HYPR-RICE---\\n'; hyprctl -j activewindow"]
        stdout: StdioCollector {
            id: snapshotOutput

            onStreamFinished: {
                const chunks = snapshotOutput.text.split("\n---HYPR-RICE---\n")
                if (chunks.length < 3)
                    return

                try {
                    const parsedWorkspaces = JSON.parse(chunks[0])
                    const active = JSON.parse(chunks[1])
                    const activeWindow = JSON.parse(chunks[2])
                    root.workspaces = parsedWorkspaces
                    root.activeWorkspace = active.id ?? root.activeWorkspace
                    root.activeTitle = activeWindow.title ?? ""
                    root.activeClass = activeWindow.class ?? ""
                } catch (error) {
                    console.log("hypr-rice: failed to parse hyprctl snapshot", error)
                }
            }
        }
    }
}
