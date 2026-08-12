pragma ComponentBehavior: Bound

import QtQuick
import qs.state
import qs.config
import qs.modules.notch.panels.components

Rectangle {
    id: root

    color: "transparent"

    anchors.topMargin: Config.constants.spacing
    anchors.leftMargin: Config.constants.spacing
    anchors.rightMargin: Config.constants.spacing

    anchors.fill: parent

    BackButton {
        id: backButton
        text: 'Notifications'
    }

    ListView {
        id: notificationsList

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: backButton.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Config.constants.spacing

        model: NotificationsState.notifications

        delegate: Rectangle {
            required property var modelData
            width: notificationsList.width
            height: 60
            radius: 6
            color: Config.colors.base

            Text {
                anchors.centerIn: parent
                text: modelData.title

                color: "white"
            }
        }
    }
}
