pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.state
import qs.config
import qs.components
import qs.modules.notch.panels.components
import qs.modules.notch.panels.notifications as NotificationsModule

Rectangle {
    id: root

    color: "transparent"

    anchors.fill: parent
    anchors.topMargin: Config.constants.spacing
    anchors.leftMargin: Config.constants.spacing
    anchors.rightMargin: Config.constants.spacing

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.constants.spacing / 2

        RowLayout {
            Layout.fillWidth: true

            BackButton {
                text: 'Notifications'
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: 'Do not disturb'
                font.pixelSize: 13
                color: Config.colors.secondaryLight

                Layout.alignment: Qt.AlignVCenter
            }

            CustomSwitch {
                checked: NotificationsState.silent
                onToggled: NotificationsState.silent = checked
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: 15
            }
        }

        ListView {
            id: notificationsList

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: NotificationsState.notifications

            delegate: NotificationsModule.NotificationCard {
                width: notificationsList.width
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: NotificationsState.notifications.length === 0
        text: 'No notifications'
        font.pixelSize: 13
        color: Config.colors.secondaryLight
    }
}
