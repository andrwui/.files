pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import qs.state
import qs.config
import qs.components
import QtQuick.Controls
import Quickshell.Services.Notifications
import QtQuick.Effects
import qs.modules.notch.panels

Rectangle {
    id: notch

    required property var items

    property int targetWidth: Config.constants.notchHomeLayoutWidth
    property int targetHeight: Config.constants.notchHomeLayoutHeight
    property int targetRadius: Config.constants.spacing
    property int enterWait: 0
    property string lastPanelName: ''

    width: targetWidth
    height: targetHeight

    clip: false

    border.color: Config.colors.secondaryDark
    border.width: 1

    Behavior on width {
        Anim {}
    }
    Behavior on height {
        Anim {}
    }
    Behavior on radius {
        NumberAnimation {
            duration: Config.animations.duration
            easing.type: Config.animations.easingType
        }
    }

    color: Config.colors.base
    radius: targetRadius

    anchors.horizontalCenter: parent.horizontalCenter

    NotificationServer {
        id: notificationServer
        onNotification: n => {
            if (NotchState.activePanel || notchHover.hovered)
                return;
            NotificationsState.addNotification({
                title: n.summary,
                body: n.body,
                icon: n.appIcon,
                image: n.image,
                timeout: n.expireTimeout,
                date: new Date()
            });

            NotchState.activePanel = Panels.emergentNotification;
            emergentTimer.interval = 2000;
            emergentTimer.running = true;
        }
    }

    Timer {
        id: emergentTimer
        interval: 1000
        repeat: false
        onTriggered: {
            NotchState.activePanel = null;
        }
    }

    HoverHandler {
        id: notchHover
        onHoveredChanged: {
            if (!notchHover.hovered && NotchState.activePanel) {
                NotchState.activePanel = null;
                CalendarState.reset();
            }
        }
    }

    Component {
        id: homeLayout
        NotchHomeLayout {
            items: notch.items
        }
    }

    Connections {
        target: NotchState
        function onActivePanelChanged() {
            var openingEmergent = NotchState.activePanel && NotchState.activePanel.name === 'emergent';
            var closingEmergent = NotchState.activePanel === null && notch.lastPanelName === 'emergent';
            notch.lastPanelName = NotchState.activePanel ? NotchState.activePanel.name : '';

            if (openingEmergent || closingEmergent) {
                notch.enterWait = Config.animations.duration;
                sizeTimer.running = true;
            } else {
                notch.enterWait = 0;
                sizeTimer.stop();
                notch.targetWidth = NotchState.activePanel ? NotchState.activePanel.width : Config.constants.notchHomeLayoutWidth;
                notch.targetHeight = NotchState.activePanel ? NotchState.activePanel.height : Config.constants.notchHomeLayoutHeight;
                notch.targetRadius = NotchState.activePanel ? NotchState.activePanel.radius : Config.constants.spacing;
            }

            if (NotchState.activePanel) {
                notchStack.replace(NotchState.activePanel.panel);
            } else {
                notchStack.replace(homeLayout);
            }
        }
    }

    Timer {
        id: sizeTimer
        interval: Config.animations.duration
        repeat: false
        onTriggered: {
            notch.targetWidth = NotchState.activePanel ? NotchState.activePanel.width : Config.constants.notchHomeLayoutWidth;
            notch.targetHeight = NotchState.activePanel ? NotchState.activePanel.height : Config.constants.notchHomeLayoutHeight;
            notch.targetRadius = NotchState.activePanel ? NotchState.activePanel.radius : Config.constants.spacing;
        }
    }

    MultiEffect {
        id: blurFx
        anchors.fill: parent
        source: blurBg
        blurEnabled: true
        blur: 130
        blurMax: 130

        Rectangle {
            id: blurBg
            anchors.fill: parent
            radius: notch.radius
            color: Config.colors.base

            StackView {
                id: notchStack
                initialItem: homeLayout
                anchors.fill: parent

                replaceEnter: Transition {
                    SequentialAnimation {
                        PropertyAnimation {
                            property: "opacity"
                            from: 0
                            to: 0
                            duration: notch.enterWait
                        }
                        ParallelAnimation {
                            PropertyAnimation {
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 300
                                easing.type: Config.animations.easingType
                            }
                            PropertyAnimation {
                                property: "scale"
                                from: 0.8
                                to: 1
                                duration: 300
                                easing.type: Config.animations.easingType
                            }
                            PropertyAnimation {
                                target: blurFx
                                property: "blur"
                                from: 1
                                to: 0
                                duration: 300
                                easing.type: Config.animations.easingType
                            }
                        }
                    }
                }

                replaceExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 300
                        easing.type: Config.animations.easingType
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 1
                        to: 0.8
                        duration: 300
                        easing.type: Config.animations.easingType
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: notch.radius
        color: 'transparent'
        border.color: notch.border.color
        border.width: notch.border.width
    }
}
