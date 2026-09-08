pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.state
import qs.config
import qs.components

Rectangle {
    id: root

    required property var modelData
    required property int index

    implicitHeight: 56
    radius: 15
    color: Config.colors.base
    border.color: Config.colors.secondaryDark
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: Config.constants.spacing / 2
        spacing: Config.constants.spacing / 2

        Rectangle {
            width: 36
            height: 36
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 999
            clip: true
            color: Config.colors.foreground

            Image {
                anchors.fill: parent
                visible: root.modelData && !!root.modelData.image
                source: root.modelData ? root.modelData.image : ''
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Image {
                anchors.fill: parent
                visible: root.modelData && !root.modelData.image && root.modelData.icon
                source: root.modelData && root.modelData.icon ? Quickshell.iconPath(root.modelData.icon) : ''
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !(root.modelData && (root.modelData.image || root.modelData.icon))
                text: root.modelData && root.modelData.title ? root.modelData.title[0] : ''
                font.pixelSize: 14
                font.bold: true
                color: Config.colors.base
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.modelData ? root.modelData.title : ''
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    color: Config.colors.foreground
                }

                Text {
                    text: root.modelData && root.modelData.date ? Qt.formatDateTime(root.modelData.date, "hh:mm") : ''
                    font.pixelSize: 11
                    color: Config.colors.secondaryLight
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.modelData ? root.modelData.body : ''
                font.pixelSize: 13
                elide: Text.ElideRight
                maximumLineCount: 1
                color: Config.colors.secondaryLight
            }
        }

        ShrinkButton {
            Layout.alignment: Qt.AlignTop
            width: Config.constants.spacing
            height: Config.constants.spacing
            onClicked: NotificationsState.removeNotification(root.index)

            Text {
                anchors.centerIn: parent
                text: 'x'
                font.pixelSize: 13
                font.bold: true
                color: Config.colors.secondaryLight
            }
        }
    }
}
