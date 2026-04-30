pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.config

StackView {
    id: root

    required property int value
    required property ListModel items
    required property int openHeight

    initialItem: button

    signal change(index: int)

    replaceEnter: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            property: "scale"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    replaceExit: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 200
            easing.type: Easing.OutQuart
        }
        PropertyAnimation {
            property: "scale"
            from: 1
            to: 0
            duration: 200
            easing.type: Easing.OutQuart
        }
    }

    Component {
        id: button
        Rectangle {
            width: root.width
            height: root.height

            radius: 10
            color: Config.colors.base

            MouseArea {

                onClicked: root.replace(list)

                width: parent.width
                height: parent.height

                cursorShape: Qt.PointingHandCursor

                BaseText {
                    anchors.centerIn: parent
                    text: root.items.get(root.value).label
                    color: Config.colors.foreground
                    scale: parent.pressed ? 0.8 : 1
                    Behavior on scale {
                        Anim {}
                    }
                }
            }
        }
    }

    Component {
        id: list
        Rectangle {
            height: root.openHeight
            width: root.width
            radius: 10

            color: Config.colors.base

            ListView {
                model: root.items
                clip: true
                z: 10

                currentIndex: root.value

                anchors.fill: parent

                delegate: Rectangle {
                    required property var model
                    required property var index

                    width: ListView.view.width
                    height: root.height

                    radius: 10
                    color: index === root.value ? Config.colors.foreground : Config.colors.base

                    Behavior on color {
                        Anim {}
                    }

                    BaseText {
                        anchors.centerIn: parent
                        text: parent.model.label
                        font.bold: parent.index === root.value
                        color: parent.index === root.value ? Config.colors.base : Config.colors.foreground
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: false
                        onClicked: {
                            root.change(parent.index);
                            root.replace(button);
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
