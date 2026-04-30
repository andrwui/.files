pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.config
import qs.state

Rectangle {
    id: root

    width: 400
    height: 300

    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    property int year: CalendarState.currentYear
    property int month: CalendarState.currentMonth

    ColumnLayout {
        width: parent.width - 80
        height: parent.height - 40

        anchors.centerIn: parent

        spacing: 0

        RowLayout {
            z: 20
            height: 35

            ShrinkButton {

                height: parent.height
                width: 15

                onClicked: CalendarState.currentYear--

                CustomIcon {
                    iconName: 'left'
                    width: 10
                    height: 10
                }
            }

            Rectangle {
                height: 35
                Layout.fillWidth: true
                color: 'transparent'

                radius: 10

                PopupSelect {

                    height: parent.height
                    width: parent.width

                    openHeight: 75

                    items: CalendarState.years
                    value: CalendarState.currentYear

                    onChange: index => CalendarState.currentYear = index
                }
            }

            ShrinkButton {

                height: parent.height
                width: 15

                onClicked: CalendarState.currentYear++

                CustomIcon {
                    iconName: 'right'
                    width: 10
                    height: 10
                }
            }

            ShrinkButton {

                height: parent.height
                width: 15

                onClicked: CalendarState.currentMonth--

                CustomIcon {
                    iconName: 'left'
                    width: 10
                    height: 10
                }
            }

            Rectangle {
                height: 35
                Layout.fillWidth: true
                color: Config.colors.base
                PopupSelect {

                    height: parent.height
                    width: parent.width

                    openHeight: 75

                    items: CalendarState.months
                    value: CalendarState.currentMonth

                    onChange: index => CalendarState.currentMonth = index
                }
            }

            ShrinkButton {

                height: parent.height
                width: 15

                onClicked: CalendarState.currentMonth++

                CustomIcon {
                    iconName: 'right'
                    width: 10
                    height: 10
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
                    text: shortName.toLowerCase()
                    color: Config.colors.secondaryLight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

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

                    radius: 5

                    property bool isFirstFriday: {
                        return date.getDay() === 5 && date.getDate() <= 7;
                    }

                    opacity: month !== root.month ? 0.1 : 1

                    color: today ? Config.colors.foreground : isFirstFriday ? 'yellow' : Config.colors.base

                    height: 205

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
