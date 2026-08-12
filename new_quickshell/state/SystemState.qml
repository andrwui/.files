pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property ListModel servers: ListModel {
        id: servers
    }

    function init() {
        serversProcess.running = true;
    }

    function kill(pid) {
        killProcess.command = [`${Qt.resolvedUrl('../')}/binaries/pcdata`, 'kill', pid.toString()];
        killProcess.running = true;
    }
    Process {
        id: killProcess
        command: [`${Qt.resolvedUrl('../')}/binaries/pcdata`, 'kill',]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log(data);
            }
        }
    }

    Process {
        id: serversProcess
        command: [`${Qt.resolvedUrl('../')}/binaries/pcdata`, 'servers']
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let parsedData = [];

                parsedData = JSON.parse(data);

                if (!parsedData) {
                    servers.clear();
                    return;
                }

                const incoming = {};

                for (const item of parsedData) {
                    incoming[item.Pid] = item;

                    let foundIndex = -1;
                    for (let i = 0; i < servers.count; i++) {
                        if (servers.get(i).pid === item.Pid) {
                            foundIndex = i;
                            break;
                        }
                    }

                    if (foundIndex >= 0) {
                        servers.set(foundIndex, {
                            pid: item.Pid,
                            name: item.Name,
                            port: item.Port,
                            cwd: item.Cwd,
                            memoryUsage: item.MemoryUsage,
                            createTime: item.CreateTime
                        });
                    } else {
                        servers.append({
                            pid: item.Pid,
                            name: item.Name,
                            port: item.Port,
                            cwd: item.Cwd,
                            memoryUsage: item.MemoryUsage,
                            createTime: item.CreateTime
                        });
                    }
                }

                for (let i = servers.count - 1; i >= 0; i--) {
                    const pid = servers.get(i).pid;
                    if (!incoming[pid])
                        servers.remove(i);
                }
            }
        }
    }

    Timer {
        id: systemTimer
        interval: 200
        running: true
        repeat: true

        onTriggered: {
            serversProcess.running = true;
        }
    }
}
