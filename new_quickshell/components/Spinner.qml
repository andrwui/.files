import QtQuick
import qs.components

CustomIcon {
    id: root
    iconName: 'loader'

    RotationAnimation on rotation {
        loops: Animation.Infinite
        duration: 1000
        from: 0
        to: 360
        running: root.visible
    }

    opacity: root.visible ? 1 : 0
    Behavior on opacity {
      Anim {}
    }

    scale: root.visible ? 1 : 0
    Behavior on scale {
      Anim {}
    }

}
