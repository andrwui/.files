pragma ComponentBehavior: Bound;
import QtQuick
import "../singleton"

  Text {
    id: clock
    text: Time.time
    font.bold: true
    font.pointSize: 12
    color: "#ffffff"
    anchors.centerIn: parent
}

