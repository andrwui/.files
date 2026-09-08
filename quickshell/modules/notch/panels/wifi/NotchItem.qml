import QtQuick
import qs.components
import Quickshell.Networking

Rectangle {
    id: root
    color: 'transparent'

    readonly property var wifiDevice: {
        var devices = Networking.devices ? Networking.devices.values : [];
        for (var i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    readonly property var activeNetwork: {
        if (!root.wifiDevice)
            return null;
        var networks = root.wifiDevice.networks ? root.wifiDevice.networks.values : [];
        for (var i = 0; i < networks.length; ++i) {
            if (networks[i].connected)
                return networks[i];
        }
        return null;
    }

    CustomIcon {
        iconName: {
            if (!Networking.wifiEnabled || !root.wifiDevice)
                return 'wifi/wifi-off';
            if (!root.activeNetwork)
                return 'wifi/wifi-lo';
            var strength = root.activeNetwork.signalStrength;
            if (strength > 0.66)
                return 'wifi/wifi-hi';
            if (strength > 0.33)
                return 'wifi/wifi-mid';
            return 'wifi/wifi-lo';
        }
        height: 15
        width: 15
    }
}
