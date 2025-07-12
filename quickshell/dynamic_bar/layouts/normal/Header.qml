import QtQuick
import "root:/generics"

    Rectangle {
      id: top
      implicitHeight:  35
      implicitWidth:  250
      color: '#0a0a0a'
      radius: 10

      anchors.horizontalCenter: parent.horizontalCenter

      SimpleClock { }

    }
