pragma ComponentBehavior: Bound
import qs.components
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import QtCore

Window {
    id: root
    visible: false
    color: '#111111'
    height: 450
    width: 380

    function isLink(value) {
        try {
            new URL(value);
            return true;
        } catch (e) {
            try {
                new URL(`https://${value}`);
                return true;
            } catch (e) {
                try {
                    new URL(`http://${value}`);
                    return true;
                } catch (e) {
                    return false;
                }
            }
        }
    }

    IpcHandler {
        target: 'clipboard'
        function open() {
            root.visible = true;
        }
    }

    function updateHistory() {
        fileView.reload();
        const json = JSON.parse(fileView.text());
        json.sort((a, b) => {
            if (a.pinned) {
                return -1;
            }
            if (b.pinned) {
                return 1;
            }
            return b.date - a.date;
        });
        rawData = json;
        applyFilter(searchField.text);
    }

    function applyFilter(text) {
        historyModel.clear();
        const filter = text.toLowerCase();
        for (let i = 0; i < rawData.length; i++) {
            const item = rawData[i];
            if (filter === '' || item.data.toLowerCase().includes(filter)) {
                historyModel.append({
                    id: item.id,
                    type: item.type,
                    data: item.data,
                    date: item.date,
                    pinned: item.pinned
                });
            }
        }
    }

    property var rawData: []
    property var history: ListModel {
        id: historyModel
    }

    onHistoryChanged: {
        console.log(history);
    }

    FileView {
        id: fileView
        watchChanges: true
        path: `${StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]}/.config/cliphist/history.json`

        onLoaded: () => {
            root.updateHistory();
        }

        onFileChanged: () => {
            root.updateHistory();
        }
    }

    Process {
        id: actionProcess
        running: false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10

        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.rightMargin: 10
            Layout.leftMargin: 10
            z: 500

            CustomIcon {
                z: 10
                iconName: 'search'
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.leftMargin: 10

                Layout.maximumHeight: 20
                Layout.maximumWidth: 20
            }
            Rectangle {
                anchors.fill: parent

                color: '#171717'
                border.width: 1
                border.color: '#232323'

                radius: 5
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: "Search..."
                placeholderTextColor: '#333333'

                font.pixelSize: 16
                color: 'white'

                background: Rectangle {

                    color: 'transparent'
                }

                onTextChanged: root.applyFilter(text)
            }
            ShrinkButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10

                height: 20
                width: 20

                CustomIcon {
                    z: 10
                    iconName: 'x'
                }

                onClicked: () => {
                    searchField.text = '';
                }

                visible: searchField.text !== ''
            }
        }

        ListView {
            id: listView
            model: root.history

            Layout.fillHeight: true
            Layout.fillWidth: true

            maximumFlickVelocity: 10000000
            flickDeceleration: 10000000

            boundsBehavior: Flickable.StopAtBounds
            spacing: 10
            clip: true

            ScrollBar.vertical: ScrollBar {
                active: true
                stepSize: 80
            }

            delegate: Rectangle {
                id: listItem
                required property var model
                required property var index
                clip: true

                Component.onCompleted: console.log(index)

                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter

                height: listItem.model.type === 'text' ? text.implicitHeight + 40 + (text.truncated ? text.lineHeight : 0) : (image.implicitHeight > 0 ? Math.min(image.implicitHeight + 40, 200) : 200)

                color: '#171717'
                border.width: 1
                border.color: '#232323'
                radius: 5

                Behavior on color {
                    ColorAnim {}
                }

                Text {
                    id: text
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 20
                    }
                    visible: listItem.model.type === 'text' && !root.isLink(listItem.model.data)
                    text: listItem.model.data
                    color: 'white'
                    font.pixelSize: 16
                    wrapMode: Text.Wrap
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 22
                    maximumLineCount: 4
                    clip: true
                }

                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: text.bottom
                        leftMargin: 10
                        rightMargin: 10
                    }
                    visible: listItem.model.type === 'text' && text.truncated && text.visible
                    text: '...more lines...'
                    color: '#555555'
                    font.pixelSize: 16
                    font.italic: true
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 22
                }

                Text {
                    id: linktext
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 20
                    }
                    text: listItem.model.data
                    visible: listItem.model.type === 'text' && root.isLink(listItem.model.data)
                    color: 'white'
                    textFormat: Text.PlainText
                    font.pixelSize: 16
                    wrapMode: Text.Wrap
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 22
                    maximumLineCount: 4
                    font.underline: linkmousearea.hovered
                    clip: true

                    MouseArea {
                        id: linkmousearea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Qt.openUrlExternally(listItem.model.data);
                        }
                    }
                    HoverHandler {
                        id: linkhoverhandler
                    }
                }

                Image {
                    id: image
                    visible: listItem.model.type === 'image'
                    source: `data:image/png;base64,${listItem.model.data}`
                    fillMode: Image.PreserveAspectFit
                    anchors {
                        fill: parent
                        margins: 10
                    }
                }

                RowLayout {
                    height: 30
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: {
                        top: 5;
                        right: 5;
                    }
                    spacing: 10

                    scale: itemHover.hovered ? 1 : 0.8
                    Behavior on scale {
                        Anim {}
                    }
                    opacity: itemHover.hovered ? 1 : 0
                    Behavior on opacity {
                        Anim {}
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: '#222222'
                        radius: 5
                    }

                    ShrinkButton {
                        Layout.minimumWidth: 20
                        Layout.minimumHeight: 20
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.maximumWidth: 20
                        Layout.maximumHeight: 20

                        CustomIcon {
                            iconName: 'copy'
                        }

                        onClicked: () => {
                            actionProcess.command = listItem.model.type === 'text' ? ['wl-copy', listItem.model.data] : ['sh', '-c', `echo -n ${listItem.model.data} | base64 -d | wl-copy`];
                            actionProcess.running = true;
                            listView.positionViewAtIndex(0, ListView.Center);
                        }
                    }

                    ShrinkButton {
                        Layout.minimumWidth: 20
                        Layout.minimumHeight: 20
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.maximumWidth: 20
                        Layout.maximumHeight: 20

                        CustomIcon {
                            iconName: listItem.model.pinned ? 'pin-on' : 'pin'
                        }
                        onClicked: () => {
                            actionProcess.command = ['sh', '-c', `cliphist --pin ${listItem.model.id}`];
                            actionProcess.running = true;
                        }
                    }

                    ShrinkButton {
                        Layout.minimumWidth: 20
                        Layout.minimumHeight: 20
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.maximumWidth: 20
                        Layout.maximumHeight: 20

                        CustomIcon {
                            iconName: 'trash'
                        }
                        onClicked: () => {
                            actionProcess.command = ['sh', '-c', `cliphist --delete ${listItem.model.id}`];
                            actionProcess.running = true;
                        }
                    }
                }

                HoverHandler {
                    id: itemHover
                    onHoveredChanged: () => {
                        if (hovered) {
                            listItem.color = '#222222';
                        } else {
                            listItem.color = '#171717';
                        }
                    }
                }
            }
        }
    }
}
