import Quickshell
import QtQuick
import QtQuick.Layouts
import "music"
import "layouts/normal"
import "layouts/applauncher"

PanelWindow {

  id: dynamic_bar

  property var ease: Easing.OutCirc

  margins.top: 5

  anchors.top: true

  exclusionMode: ExclusionMode.Ignore

  color: 'transparent'

  implicitHeight: 550
  implicitWidth: 1920


  mask: Region { item: layout }

  RowLayout {
    id: layout

    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle {
      id: container

      implicitHeight: hover.hovered ? 400 : 35
      implicitWidth: hover.hovered ? 800 : 250

      clip: true
      z: 100


      color: '#0a0a0a'
      radius: 10


      HoverHandler {
        id: hover
      }

      Behavior on implicitHeight {
        NumberAnimation {
          duration: 250
          easing.type: dynamic_bar.ease
        }
      }

      Behavior on implicitWidth {
        NumberAnimation {
          duration: 250
          easing.type:dynamic_bar.ease 
        }
      }


      // NormalLayout {}
      AppLauncher {
        windows: [dynamic_bar]
      }

    }

    Music { }

  }


}

