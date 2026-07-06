import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property var workspaces: []
    property int activeWorkspace: 1
    property string activeTitle: ""
    property string activeClass: ""

    function dispatch(command) {
        Quickshell.execDetached(["hyprctl", "dispatch"].concat(command.split(" ")))
    }

    // Only queries heavy JSON on boot, or if a window/workspace is physically added/removed
    function refreshWorkspaces() {
        if (!snapshot.running) snapshot.running = true
    }

    Component.onCompleted: refreshWorkspaces()

    Timer {
        id: refreshDebounce
        interval: 100
        repeat: false
        onTriggered: root.refreshWorkspaces()
    }

    // 1. The structural snapshot
    Process {
        id: snapshot
        command: ["sh", "-c", "hyprctl -j workspaces; printf '\\n---HYPR-RICE---\\n'; hyprctl -j activeworkspace; printf '\\n---HYPR-RICE---\\n'; hyprctl -j activewindow; printf '\\n---HYPR-RICE---\\n'; hyprctl -j clients"]
        stdout: StdioCollector {
            id: snapshotOutput
            onStreamFinished: {
                const chunks = snapshotOutput.text.split("\n---HYPR-RICE---\n")
                if (chunks.length < 4) return
                try {
                    const rawWorkspaces = JSON.parse(chunks[0])
                    const clients = JSON.parse(chunks[3])
                    
                    // Enrich workspaces with window class lists
                    for (const ws of rawWorkspaces) {
                        ws.windowClasses = clients
                            .filter(c => c.workspace && c.workspace.id === ws.id)
                            .map(c => c.class || "unknown")
                            .slice(0, 6) // Max 6 icons in tooltip
                    }
                    
                    root.workspaces = rawWorkspaces
                    root.activeWorkspace = JSON.parse(chunks[1]).id ?? root.activeWorkspace
                    const activeWindow = JSON.parse(chunks[2])
                    root.activeTitle = activeWindow.title ?? ""
                    root.activeClass = activeWindow.class ?? ""
                } catch (error) {
                    console.log("hypr-rice: failed to parse hyprctl snapshot", error)
                }
            }
        }
    }

    // 2. The zero-overhead Socket Listener
    Process {
        id: socatListener
        running: true
        // Streams events instantly from Hyprland without polling
        command: ["sh", "-c", "socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (line.startsWith("workspace>>")) {
                    root.activeWorkspace = parseInt(line.split(">>")[1])
                } else if (line.startsWith("activewindowv2>>")) {
                    const parts = line.split(">>")[1].split(",")
                    root.activeClass = parts[0]
                    root.activeTitle = parts.slice(1).join(",")
                } else if (line.match(/^(createworkspace|destroyworkspace|openwindow|closewindow|movewindow)>>/)) {
                    refreshDebounce.restart()
                }
            }
        }
    }
}