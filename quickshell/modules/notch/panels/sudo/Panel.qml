pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.state
import qs.modules.notch.panels.components

Rectangle {
    id: root
    color: 'transparent'

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Config.constants.spacing
        spacing: Config.constants.spacing / 2

        BackButton {
            text: 'Sudo'
            Layout.fillWidth: true
            onClicked: SudoState.cancel()
        }

        Text {
            text: 'Enter sudo password'
            font.pixelSize: 15
            font.bold: true
            color: Config.colors.foreground
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: 6
            color: Config.colors.secondaryDark

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: Config.colors.foreground
                font.pixelSize: 15
                onAccepted: root.submit()
            }
        }

        Text {
            visible: SudoState.authError !== ''
            text: SudoState.authError
            color: Config.colors.error
            font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Config.constants.spacing / 2

            ShrinkButton {
                width: 70
                height: 28
                onClicked: SudoState.cancel()

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    Text {
                        anchors.centerIn: parent
                        text: 'Cancel'
                        font.pixelSize: 13
                        color: Config.colors.foreground
                    }
                }
            }

            ShrinkButton {
                width: 70
                height: 28
                onClicked: root.submit()

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Config.colors.secondaryDark

                    Text {
                        anchors.centerIn: parent
                        text: 'OK'
                        font.pixelSize: 13
                        font.bold: true
                        color: Config.colors.foreground
                    }
                }
            }
        }
    }

    function submit() {
        SudoState.submitPassword(passwordInput.text);
        passwordInput.text = '';
    }

    Component.onCompleted: {
        passwordInput.text = '';
        passwordInput.forceActiveFocus();
    }

    Connections {
        target: SudoState
        function onShowPopupChanged() {
            if (SudoState.showPopup) {
                passwordInput.text = '';
                passwordInput.forceActiveFocus();
            }
        }
    }
}
