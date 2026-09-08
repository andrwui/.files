import QtQuick
import qs.components
import qs.config

import qs.state

ShrinkButton {
    id: root
    required property string text

    height: Config.constants.spacing
    width: parent.width

    CustomIcon {
        id: icon
        iconName: 'left'
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    BaseText {
        text: root.text
        anchors.left: icon.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
    }

    onClicked: {
        NotchState.activePanel = null;
    }
}
