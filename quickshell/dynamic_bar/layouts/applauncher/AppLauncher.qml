import QtQuick
import Quickshell.Hyprland

  Rectangle {
    id: workspaces

    property alias windows: focus.windows

    color: 'transparent'

    width: 240
    height: 25

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 5

    radius: 5

    border.color: '#222222'
    border.width: 2



    TextInput {
      id: input

      focus: true
      activeFocusOnPress: true

      color: 'white'
      font.pixelSize: 18

      Keys.onEscapePressed: (event) => {
        input.focus = false
        focus.active = false
      }

    }

    HyprlandFocusGrab {
      id: focus
      windows: [bar]
    }

  GlobalShortcut {
    appid: 'bar'
    name: 'color'
    onPressed: () => {
      focus.active = true
      input.focus = true
    }
  }
  }



