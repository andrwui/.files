import QtQuick
import Quickshell
import qs.components
import qs.config

Rectangle {
    width: 200
    height: 35
    color: "transparent"
    BaseText {
        anchors.centerIn: parent
        color: Config.colors.foreground
        text: parent.time.toLowerCase()
    }

    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd, dd MMM yyyy");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
