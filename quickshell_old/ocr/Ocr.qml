pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.components
import QtQuick.Layouts

Window {
    id: root
    visible: false
    color: '#111111'
    height: 55
    width: 350

    property string text: ''

    onVisibleChanged: {
        if (!visible) {
            root.text = "";
            stack.replace(pendingComponent);
        }
    }

    Process {
        id: copyProcess
        running: false
    }

    StackView {
        id: stack
        anchors.fill: parent

        initialItem: pendingComponent

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
            id: inputComponent
            RowLayout {
                anchors.fill: parent
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                clip: true

                TextInput {
                    id: input
                    text: root.text
                    readOnly: true
                    color: '#ffffff'
                    font.pixelSize: 16
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    verticalAlignment: TextInput.AlignVCenter
                }

                ShrinkButton {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.rightMargin: 2
                    height: 20
                    width: 20
                    onClicked: () => {
                        copyProcess.command = ['wl-copy', input.text];
                        copyProcess.running = true;
                    }

                    Rectangle {

                        color: '#111111'

                        anchors.fill: parent

                        CustomIcon {
                            iconName: 'copy'
                        }
                    }
                }
            }
        }

        Component {
            id: pendingComponent
            RowLayout {
                anchors.fill: parent
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                Text {
                    text: 'Processing...'
                    color: '#ffffff'
                    font.pixelSize: 16
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.DemiBold
                }
                Spinner {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: true
                }
            }
        }
    }

    IpcHandler {
        target: 'ocr'
        function process() {
            ocrRunner.running = true;
            root.visible = true;
        }
    }

    Process {
        id: ocrRunner
        running: false
        command: ['sh', '-c', `cat /tmp/ocr | wl-ocr`]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var output = this.text.trim();
                if (output === '') {
                    root.visible = false;
                    return;
                }
                root.text = output;
                stack.replace(inputComponent);
            }
        }

        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var output = this.text.trim();
                console.log("error:" + output);
            }
        }
    }
}
