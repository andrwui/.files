pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isConnected: false
    property bool isWaiting: false

    function connect() {
        vpnProcess.running = false;
        vpnProcess.running = true;
    }

    function disconnect() {
      vpnProcess.running = false;
    }

    Process {
        id: vpnProcess
        running: false
        command: ['sudo', 'openfortivpn']
    }

    Timer {
        id: vpnCheckTimer
        interval: 200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: vpnCheckProcess.running = true
    }

    Process {
        id: vpnCheckProcess
        running: false
        command: ['sh', '-c', 'ip link show ppp0 >/dev/null 2>&1 && echo connected || (pgrep -x openfortivpn >/dev/null && echo waiting || echo disconnected)']

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var output = this.text.trim();
                if (output === "connected") {
                    root.isConnected = true;
                    root.isWaiting = false;
                } else if (output === "waiting") {
                    root.isConnected = false;
                    root.isWaiting = true;
                } else {
                    root.isConnected = false;
                    root.isWaiting = false;
                }
            }
        }
    }
}
