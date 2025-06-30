import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
  id: root 

  property real window_height
  property real window_width
  property real window_contents

  PanelWindow {

    anchors {
      top: true
      left: true
      right: true
    }

    margins {
      top: 5
      left: 5
      right: 5
    }

    implicitHeight: 35
    color: 'transparent'

    WlrLayershell.namespace: "shell:bar"

    Rectangle {
      anchors.fill: parent
      color: '#080808'
      radius: 5

      RowLayout {

        MouseArea {
          implicitWidth: 80

          hoverEnabled: true

          onEntered: () => {
            root.window_height = 200

          }
          onExited: () => {
            root.window_height = 0
          }

          Text {
            text: 'Hola mundo'
            color: 'white'
          }
        }

        MouseArea {
          implicitWidth: 80

          hoverEnabled: true

          onEntered: () => {
            root.window_height = 200

          }
          onExited: () => {
            root.window_height = 0
          }

          Text {
            text: 'Chau mundo'
            color: 'white'
          }
        }


      }
      

    }


    FloatingWindow {
      id: floating
      visible: root.window_height > 0 
    }


  }
}


