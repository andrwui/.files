import Quickshell.Services.Mpris
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  anchors.top: parent.top

  implicitWidth: hover.hovered ? 50 + songText.width : 35 
  implicitHeight: 35

  Layout.leftMargin: !!spoti && spoti.isPlaying ? 0 : -50 

  color: '#0a0a0a'
  radius: 10
  z: 10

  property var players: Mpris.players.values
  property MprisPlayer spoti: null

  onPlayersChanged: () => {
    const isThereSpoti = players.filter(player => player.identity === "Spotify")[0]
    spoti = isThereSpoti || null
  }

  Behavior on Layout.leftMargin {
    NumberAnimation { duration: 250; easing.type: Easing.InCirc }
  }

  Behavior on bottomRightRadius {
    NumberAnimation { duration: 150; easing.type: Easing.InCirc }
  }

  Behavior on topRightRadius {
    NumberAnimation { duration: 150; easing.type: Easing.InCirc }
  }

  Behavior on implicitWidth {
    NumberAnimation { duration: 250; easing.type: Easing.InCirc }
  }

  HoverHandler { id: hover }

  MouseArea {
    enabled: true
    anchors.fill: parent
    onClicked: () => Hyprland.dispatch('focuswindow class:^(Spotify)$')
  }

  Item {
    id: blurSource
    anchors.fill: parent
    visible: true
    layer.enabled: true

    RowLayout {
      id: row
      anchors.fill: parent

      Rectangle {
        implicitWidth: 35
        implicitHeight: 35
        color: 'transparent'

        Image {
          id: img
          anchors.centerIn: parent
          sourceSize: "18x18"
          source: "/home/andrw/.files/ags_new_old/icons/i-song.svg"
          scale: !!root.spoti && root.spoti.isPlaying ? 1 : 0 
          opacity: !!root.spoti && root.spoti.isPlaying ? 1 : 0 

          Behavior on scale {
            NumberAnimation { duration: 250; easing.type: Easing.InCirc }
          }
          Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.InCirc }
          }

        } 
      }

        Rectangle {
          id: songName

          implicitHeight: 35
          Layout.fillWidth: true
          radius: 10
          color: "#0a0a0a"

          Text {
            id: songText
            anchors.verticalCenter: parent.verticalCenter
            color: '#d8d8d8' 
            text: root.spoti.trackArtist + " - " + root.spoti.trackTitle
            font.bold: true
          }
        }
      }
    }

  }

