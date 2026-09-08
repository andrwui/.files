import QtQuick
import qs.state
import qs.components
import qs.config
import QtQuick.Layouts
import qs.modules.notch.panels.components

Rectangle {
    id: root

    color: "transparent"

    property int maxHeight: 300
    property int itemHeight: Config.constants.spacing * 2

    anchors.topMargin: Config.constants.spacing
    anchors.leftMargin: Config.constants.spacing
    anchors.rightMargin: Config.constants.spacing

    anchors.fill: parent

    BackButton {
        id: backButton
        text: 'Servers'
    }

    Flickable {
        id: flick

        clip: true
        contentHeight: content.implicitHeight
        interactive: contentHeight > root.maxHeight

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: backButton.top
        anchors.bottom: parent.bottom
        anchors.topMargin: Config.constants.spacing

        Column {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right

            visible: SystemState.servers.count > 0

            ListView {
                id: serversList

                width: parent.width
                height: contentHeight

                model: SystemState.servers
                interactive: false

                delegate: Rectangle {
                    width: serversList.width
                    height: root.itemHeight + Config.constants.spacing
                    radius: 6
                    color: 'transparent'

                    HoverHandler {
                        id: itemHover
                        onHoveredChanged: {
                            if (itemHover.hovered) {
                                killButton.opacity = 1;
                                killButton.scale = 1;
                            } else {
                                killButton.opacity = 0;
                                killButton.scale = 0.7;
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        Layout.alignment: Qt.AlignVCenter

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Row {
                                Layout.fillWidth: true
                                Layout.fillHeight: false
                                spacing: Config.constants.spacing / 2
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: model.cwd.split("/").slice(-1)[0]
                                    color: "white"
                                    font.pixelSize: 15
                                    font.bold: true

                                    Layout.fillHeight: false
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: model.name.split("(")[0].trim()
                                    font.pixelSize: 15
                                    color: Config.colors.secondaryLight

                                    Layout.fillHeight: false
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            Row {
                                Layout.fillWidth: true
                                spacing: Config.constants.spacing / 2

                                Layout.fillHeight: false
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: model.port
                                    font.pixelSize: 13
                                    color: Config.colors.secondaryLight

                                    Layout.fillHeight: false
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: "|"
                                    font.pixelSize: 13
                                    color: Config.colors.secondaryDark

                                    Layout.fillHeight: false
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: "ram: " + Math.round(Number(model.memoryUsage)) + "%"
                                    font.pixelSize: 13
                                    color: Config.colors.secondaryLight

                                    Layout.fillHeight: false
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }

                        ShrinkButton {
                            width: root.itemHeight
                            Layout.preferredHeight: root.itemHeight

                            onClicked: SystemState.kill(model.pid)

                            Rectangle {
                                id: killButton
                                opacity: 0
                                scale: 0.7
                                anchors.fill: parent
                                radius: 10
                                color: "white"

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: root.itemHeight / 3
                                    height: root.itemHeight / 3
                                    radius: 2
                                    color: Config.colors.base
                                }

                                Behavior on opacity {
                                    Anim {}
                                }

                                Behavior on scale {
                                    Anim {}
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: secondList

                width: parent.width
                height: contentHeight

                model: ListModel {}
                spacing: 6
                interactive: false

                delegate: Rectangle {
                    width: secondList.width
                    height: 50
                    radius: 6
                    color: "#444"

                    Text {
                        anchors.centerIn: parent
                        text: "placeholder"
                        color: "white"
                    }
                }
            }
        }
    }
    BaseText {
        anchors.centerIn: parent
        anchors.topMargin: 50
        visible: SystemState.servers.count === 0

        text: "No servers up"
        font.pixelSize: 15
        color: Config.colors.secondaryLight
    }
}
