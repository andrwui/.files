import QtQuick
import qs.components
import Quickshell.Bluetooth

Rectangle {
    color: 'transparent'

    CustomIcon {
        iconName: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
            ? 'bluetooth/bluetooth'
            : 'bluetooth/bluetooth-off'
        height: 15
        width: 15
    }
}
