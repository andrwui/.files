pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import '../globals'


PanelWindow {
  id: bar

  color: 'transparent'
  mask: {}

  exclusiveZone: 35

  anchors {
    top: true
    left: true
    right: true
  }


  implicitHeight: 35

  margins {
    top: 5
    left: 5
    right: 5
  }

  Rectangle {

    implicitHeight: 35
    implicitWidth: row.implicitWidth + 20

    clip: true

    color: '#0a0a0a'


    radius: 10

    Behavior on implicitWidth {
      NumberAnimation {
        duration: 250
        easing.type: Easing.OutSine
      }
    }

    RowLayout {
      id: row
      anchors.verticalCenter: parent.verticalCenter
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10

      Behavior on implicitWidth {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutSine
        }
      }



      Repeater {
        model: Hyprland.workspaces

        Rectangle {
          id: workspace

          required property HyprlandWorkspace modelData

          color: modelData.id === Hyprland.focusedWorkspace.id ? '#d8d8d8' : '#222222'

          implicitWidth: modelData.id === Hyprland.focusedWorkspace.id ? 35 : 15 
          implicitHeight: 15

          radius: 5


          Behavior on implicitWidth {
            NumberAnimation {
              duration: 250
              easing.type: Easing.OutSine
            }
          }

          Behavior on color {
            ColorAnimation {
              duration: 100
              easing.type: Easing.OutSine
            }
          }

        }


      }

    }

  }


}



