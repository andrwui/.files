import QtQuick
import Quickshell
import qs.state
import qs.config
import QtQuick.Layouts
import qs.components

Rectangle {
    id: root

    color: 'transparent'

    readonly property var current: NotificationsState.notifications.length > 0 ? NotificationsState.notifications[NotificationsState.notifications.length - 1] : null

    ShrinkButton {
        id: closeButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Config.constants.spacing * 1
        anchors.topMargin: Config.constants.spacing * 1
        onClicked: NotchState.activePanel = null
        height: Config.constants.spacing
        width: Config.constants.spacing

        Text {
            anchors.centerIn: parent
            text: 'x'
            color: Config.colors.secondaryLight
            font.pixelSize: 15
            font.bold: true
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Config.constants.spacing

        anchors.topMargin: Config.constants.spacing
        anchors.bottomMargin: Config.constants.spacing
        anchors.leftMargin: Config.constants.spacing
        anchors.rightMargin: Config.constants.spacing

        Rectangle {
            width: Config.constants.spacing * 2
            height: Config.constants.spacing * 2
            Layout.preferredWidth: Config.constants.spacing * 2
            Layout.preferredHeight: Config.constants.spacing * 2
            Layout.fillWidth: false
            Layout.fillHeight: false

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            radius: 999
            clip: true
            color: Config.colors.foreground

            Image {
                anchors.fill: parent
                visible: root.current && root.current.image
                source: root.current ? root.current.image : ''
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Image {
                anchors.fill: parent
                visible: root.current && !root.current.image && root.current.icon
                source: root.current && root.current.icon ? Quickshell.iconPath(root.current.icon) : ''
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !(root.current && (root.current.image || root.current.icon))
                text: root.current && root.current.title ? root.current.title.split('')[0] : ''
                font.pixelSize: 15
                color: Config.colors.base
                font.bold: true
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                Layout.fillWidth: true
                text: root.current ? root.current.title : ''
                font.pixelSize: 15
                font.bold: true
                color: Config.colors.foreground
            }
            Text {
                Layout.fillWidth: true
                text: root.current ? root.current.body : ''
                color: Config.colors.foreground
                font.pixelSize: 14
                elide: Text.ElideRight
            }
        }
    }
}
