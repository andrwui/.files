import QtQuick
import Quickshell
import qs.config

Rectangle {
    id: root
    color: 'transparent'
    width: 200

    anchors.centerIn: parent
    anchors.rightMargin: 10

    Text {
        id: text
        text: root.time
        color: Config.colors.foreground

        anchors.centerIn: parent

        font.bold: true
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
