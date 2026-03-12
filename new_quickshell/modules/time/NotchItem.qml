import QtQuick
import Quickshell

Rectangle {
    id: root
    color: 'transparent'
    width: 200

    anchors.centerIn: parent
    anchors.rightMargin: 10

    Text {
        id: text
        text: root.time
        color: 'white'

        anchors.centerIn: parent

        font.family: 'Geist'
        font.pixelSize: 16
    }

    property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
