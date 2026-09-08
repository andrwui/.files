pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isConnected: false
    property bool isWaiting: false

    readonly property bool active: isConnected || isWaiting

    property bool _wasConnected: false

    function connect() {
        root.isWaiting = true;
        SudoState.runPersistent(['openfortivpn']);
    }

    function disconnect() {
        SudoState.stopPersistent();
        SudoState.run(['pkill', '-x', 'openfortivpn'], (success) => {
            // polling confirms actual state
        });
        root.isConnected = false;
        root.isWaiting = false;
    }

    function notifyVpn(title, body) {
        vpnNotify.command = ['notify-send', title, body];
        vpnNotify.running = true;
    }

    onIsConnectedChanged: {
        if (isConnected) {
            root._wasConnected = true;
            notifyVpn('VPN', 'Connected');
        } else if (root._wasConnected) {
            root._wasConnected = false;
            notifyVpn('VPN', 'Disconnected');
        }
    }

    Process {
        id: vpnNotify
        running: false
    }

    Timer {
        id: vpnCheckTimer
        interval: 1000
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
