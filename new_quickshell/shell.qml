import QtQuick
import Quickshell
import "./singleton"
import "./notch"
import "./components"

PanelWindow {
    id: bar
    color: 'transparent'

    height: 1080
    exclusiveZone: 35
    mask: Region {
        regions: [notchRegion]
    }

    Region {
        id: notchRegion
        item: notch
    }

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: 5

    Notch {
        id: notch
    }

    NotchTray {
        id: tray

        FadingBlurView {
            anchors.fill: parent
            currentIndex: NotchState.itemHovered

            model: [page1, page2, page3]

            Component {
                id: page1
                Rectangle {
                    radius: 10
                    width: 200
                    height: 100
                    color: "#111111"
                    Text {
                        font.family: 'Geist'
                        anchors.centerIn: parent
                        text: "Page one"
                        font.pixelSize: 18
                        color: "white"
                    }
                }
            }

            Component {
                id: page2
                Rectangle {
                    radius: 10
                    width: 200
                    height: 100
                    color: "#111111"
                    Text {
                        font.family: 'Geist'
                        anchors.centerIn: parent
                        text: "Page two"
                        font.pixelSize: 18
                        color: "white"
                    }
                }
            }

            Component {
                id: page3
                Rectangle {
                    radius: 10
                    width: 200
                    height: 100
                    color: "#111111"
                    Text {
                        font.family: 'Geist'
                        anchors.centerIn: parent
                        text: "Page three"
                        font.pixelSize: 18
                        color: "white"
                    }
                }
            }
        }
    }
}

// Window {
//     width: 960
//     height: 640
//     visible: true
//     title: "No-Flash Blur Fade"
//     color: "#080808"
//
//     Row {
//         anchors.bottom: parent.bottom
//         anchors.horizontalCenter: parent.horizontalCenter
//         anchors.bottomMargin: 50
//         spacing: 40
//
//         Repeater {
//             model: 3
//             Button {
//                 width: 140
//                 height: 60
//                 text: "Page " + (index + 1)
//                 font.pixelSize: 18
//                 highlighted: selector.currentIndex === index
//                 onClicked: selector.currentIndex = index
//             }
//         }
//     }
//
//     QtObject {
//         id: selector
//         property int currentIndex: 0
//     }
// }
