import QtQuick
import Quickshell
import qs.components

Rectangle {
    width: 200
    height: 35
    color: "transparent"
    BaseText {
        anchors.centerIn: parent
        color: 'white'
        text: parent.time
    }

    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd, dd MMM yyyy");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
