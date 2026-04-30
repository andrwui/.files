import QtQuick
import qs.state
import qs.components
import qs.config
import QtQuick.Layouts

Rectangle {
    id: root

    width: 400
    color: "transparent"

    property int maxHeight: 300
    property int itemHeight: 40

    implicitHeight: SystemState.servers.count === 0 ? itemHeight + 20 : Math.min(content.implicitHeight + 20, maxHeight)

    Flickable {
        id: flick

        anchors.fill: parent
        anchors.topMargin: 5
        anchors.leftMargin: 35
        anchors.rightMargin: 35

        clip: true
        contentHeight: content.implicitHeight
        interactive: contentHeight > root.maxHeight

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
                spacing: 10
                interactive: false

                delegate: Rectangle {
                    width: serversList.width
                    height: root.itemHeight
                    radius: 6
                    color: "transparent"

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

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Row {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10

                                Text {
                                    text: model.cwd.split("/").slice(-1)[0]
                                    color: "white"
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: model.name.split("(")[0].trim()
                                    font.pixelSize: 15
                                    color: Config.colors.secondaryLight
                                }
                            }

                            Row {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10

                                Text {
                                    text: model.port
                                    font.pixelSize: 13
                                    color: Config.colors.secondaryLight
                                }

                                Text {
                                    text: "|"
                                    font.pixelSize: 13
                                    color: Config.colors.secondaryDark
                                }

                                Text {
                                    text: "ram: " + Math.round(Number(model.memoryUsage)) + "%"
                                    font.pixelSize: 13
                                    color: Config.colors.secondaryLight
                                }
                            }
                        }

                        ShrinkButton {
                            width: root.itemHeight
                            Layout.fillHeight: true

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

        BaseText {
            anchors.centerIn: parent
            anchors.topMargin: 10
            visible: SystemState.servers.count === 0

            text: "no servers up"
            font.pixelSize: 15
            color: Config.colors.secondaryLight
        }
    }
}
