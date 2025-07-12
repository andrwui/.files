import QtQuick

Rectangle {
  anchors.fill: parent
  color: 'transparent'


  Header {
    id: header

  }

  Widgets {
    anchors.top: header.bottom
  }

}
