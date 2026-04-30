import QtQuick
import qs.components
import qs.config
import qs.state

Rectangle {

    width: 200
    height: 35
    color: "transparent"

    BaseText {
        anchors.centerIn: parent
        font.bold: false
        color: Config.colors.foreground
        text: SystemState.servers.count === 0 ? 'no servers up' : SystemState.servers.count === 1 ? '1 server up' : SystemState.servers.count + ' servers up'
    }
}
