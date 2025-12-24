pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "dd/MM        hh:mm");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
