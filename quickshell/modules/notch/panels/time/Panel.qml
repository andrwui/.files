pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.config
import qs.state
import qs.modules.notch.panels.components

Rectangle {
    id: root

    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    SystemClock {
        id: dateClock
        precision: SystemClock.Minutes
    }

    property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }

    property string date: {
        Qt.formatDateTime(dateClock.date, "dddd, MMMM d");
    }

    property int year: CalendarState.currentYear
    property int month: CalendarState.currentMonth

    ColumnLayout {

        anchors.fill: parent
        anchors.topMargin: Config.constants.spacing
        anchors.leftMargin: Config.constants.spacing
        anchors.rightMargin: Config.constants.spacing
        anchors.centerIn: parent

        spacing: Config.constants.spacing / 2

        BackButton {
            text: 'Calendar'
        }

        BaseText {
            text: root.time
            font.pixelSize: 50
            font.bold: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        BaseText {
            text: root.date
            font.pixelSize: 20
            font.bold: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        RowLayout {
            z: 20
            height: 35

            ShrinkButton {

                height: parent.height
                width: parent.height

                onClicked: CalendarState.currentMonth--

                Layout.alignment: Qt.AlignVCenter

                CustomIcon {
                    iconName: 'left'
                    anchors.centerIn: parent
                }
            }

            Item {
                Layout.fillWidth: true
            }

            BaseText {
                text: `${Config.constants.months[CalendarState.currentMonth]} ${CalendarState.currentYear} `
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            }

            Item {
                Layout.fillWidth: true
            }

            ShrinkButton {

                height: parent.height
                width: parent.height

                onClicked: CalendarState.currentMonth++

                Layout.alignment: Qt.AlignVCenter

                CustomIcon {
                    iconName: 'right'
                    anchors.centerIn: parent
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 30

            color: 'transparent'

            DayOfWeekRow {
                locale: Qt.locale("en_GB")

                width: parent.width

                delegate: BaseText {
                    required property string shortName
                    text: shortName
                    color: Config.colors.secondaryLight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: Config.constants.spacing

            color: 'transparent'

            MonthGrid {

                anchors.fill: parent
                locale: Qt.locale("en_GB")

                year: root.year
                month: root.month

                delegate: Rectangle {

                    required property date date
                    required property int day
                    required property int month
                    required property int year
                    required property bool today

                    radius: 10

                    opacity: month !== root.month ? 0.1 : today ? 0.8 : 1

                    color: today ? Config.colors.foreground : Config.colors.base

                    BaseText {

                        anchors.centerIn: parent

                        text: parent.day
                        color: parent.today ? Config.colors.base : Config.colors.foreground

                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
