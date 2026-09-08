pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool powerSaving: false

    function refresh() {
        profileReader.running = true;
    }

    function setPowerSaving(enabled) {
        console.log(`setPowerSaving: ${enabled}`);
        root.powerSaving = enabled;
        SudoState.run(
            ['sh', '-c', `echo ${enabled ? 'low-power' : 'balanced'} > /sys/firmware/acpi/platform_profile`],
            (success) => {
                console.log(`setPowerSaving result: ${success}`);
                if (!success)
                    refresh();
            }
        );
    }

    Process {
        id: profileReader
        running: false
        command: ['sh', '-c', 'cat /sys/firmware/acpi/platform_profile']

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.powerSaving = (this.text.trim() === 'low-power');
            }
        }
    }
}
