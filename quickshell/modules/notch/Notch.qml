pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import qs.state
import qs.config
import qs.components
import QtQuick.Controls
import Quickshell.Services.Notifications
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import qs.modules.notch.panels
import Quickshell.Services.UPower
import Quickshell.Io

Rectangle {
    id: notch

    required property var items

    width: NotchState.activePanel ? NotchState.activePanel.width : Config.constants.notchHomeLayoutWidth
    height: NotchState.activePanel ? NotchState.activePanel.height : Config.constants.notchHomeLayoutHeight

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
        Anim {}
    }

    color: Config.colors.base
    radius: NotchState.activePanel ? NotchState.activePanel.radius : Config.constants.spacing

    anchors.horizontalCenter: parent.horizontalCenter

    NotificationServer {
        id: notificationServer
        onNotification: n => {
            NotificationsState.addNotification({
                title: n.summary,
                body: n.body,
                icon: n.appIcon,
                image: n.image,
                timeout: n.expireTimeout,
                date: new Date()
            });

            if (NotificationsState.silent || NotchState.activePanel || NotchState.isNotchHovered)
                return;

            NotchState.activePanel = Panels.emergentNotification;
            emergentTimer.interval = Math.max(5000, n.expireTimeout * 1000);
            emergentTimer.running = true;
        }
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() {
            batteryNotifier.running = true;
        }
    }

    Connections {
        target: UPower.displayDevice
        function onPercentageChanged() {
            if (UPower.onBattery && (UPower.displayDevice.percentage == 10 || UPower.displayDevice.percentage == 20)) {
                batteryLowNotifier.running = true;
                screenBrightness.running = true;
            }
        }
    }

    Process {
        id: batteryNotifier
        running: false
        command: ['sh', '-c', `notify-send "Battery ${!UPower.onBattery ? 'connected' : 'disconnected'}" "${UPower.displayDevice.percentage * 100}% ${UPower.onBattery ? 'remaining' : 'charged'}"`]
    }

    Process {
        id: batteryLowNotifier
        running: false
        command: ['sh', '-c', `notify-send "Battery low" "${UPower.displayDevice.percentage * 100}% remaining"`]
    }

    Process {
        id: screenBrightness
        running: false
        command: ['sh', '-c', `brightnessctl set 20%`]
    }

    Timer {
        id: emergentTimer
        interval: 1000
        repeat: false
        onTriggered: {
            NotchState.activePanel = null;
        }
    }

    Connections {
        target: NotchState
        function onIsNotchHoveredChanged() {
            if (!NotchState.isNotchHovered && NotchState.activePanel) {
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
            if (SudoState.showPopup && (!NotchState.activePanel || NotchState.activePanel.name !== 'sudo')) {
                SudoState.cancel();
            }
            if (NotchState.activePanel && NotchState.activePanel.name === 'notifications') {
                NotificationsState.markAllRead();
            }
            if (NotchState.activePanel) {
                notchStack.replace(NotchState.activePanel.panel);
            } else {
                notchStack.replace(homeLayout);
            }
        }
    }

    Connections {
        target: SudoState
        function onShowPopupChanged() {
            if (SudoState.showPopup) {
                NotchState.activePanel = Panels.sudo;
            } else if (NotchState.activePanel && NotchState.activePanel.name === 'sudo') {
                NotchState.activePanel = null;
            }
        }
    }

    Rectangle {
        id: roundedMask
        anchors.fill: parent
        radius: notch.radius
        color: 'white'
        visible: false
    }

    MultiEffect {
        id: blurFx
        anchors.fill: parent
        source: blurBg
        blurEnabled: true
        blur: 0
        blurMax: 50
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: roundedMask
        }

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
                    SpringAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                    SpringAnimation {
                        property: "scale"
                        from: 0.8
                        to: 1
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                    SpringAnimation {
                        target: blurFx
                        property: "blur"
                        from: 1
                        to: 0
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                }

                replaceExit: Transition {
                    SpringAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                    SpringAnimation {
                        property: "scale"
                        from: 1
                        to: 0.8
                        spring: Config.animations.spring
                        damping: Config.animations.damping
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
