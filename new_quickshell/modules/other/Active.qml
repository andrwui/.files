import QtQuick
import qs.state
import qs.components
import qs.models.system
import QtQuick.Layouts

Rectangle {
    width: 380
    height: 200
    color: "transparent"

    ColumnLayout {
        id: serversColumn

        Repeater {
            model: SystemState.servers

            delegate: Rectangle {
                required property ServerModel modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 80
                height: 80

                color: "transparent"
                BaseText {
                    anchors.centerIn: parent
                    text: parent.modelData.name
                }
            }
        }
    }
}
