import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property int currentIndex: 0
    property var model: []
    property int fadeDuration: 200
    property var currentLoader: null
    implicitWidth: currentLoader ? (currentLoader.implicitWidth || 0) : 0
    implicitHeight: currentLoader ? (currentLoader.implicitHeight || 0) : 0

    Repeater {
        model: root.model.length

        Item {
            id: pageWrapper
            width: contentLoader.implicitWidth
            height: contentLoader.implicitHeight

            transform: {
                scale: index === root.currentIndex ? 1 : 0;
            }

            scale: index === root.currentIndex ? 1 : 0
            Behavior on scale {
                NumberAnimation {
                    duration: root.fadeDuration
                    easing.type: Easing.OutQuart
                }
            }

            Loader {
                id: contentLoader
                sourceComponent: root.model[index]
                asynchronous: true
                onLoaded: {
                    if (item) {
                        item.anchors.fill = undefined;
                        implicitWidth = item.implicitWidth || item.width;
                        implicitHeight = item.implicitHeight || item.height;
                    }
                    if (index === root.currentIndex) {
                        root.currentLoader = contentLoader;
                    }
                }
                Binding {
                    target: contentLoader
                    property: "implicitWidth"
                    value: contentLoader.item ? (contentLoader.item.implicitWidth || contentLoader.item.width) : 0
                    when: contentLoader.item
                }
                Binding {
                    target: contentLoader
                    property: "implicitHeight"
                    value: contentLoader.item ? (contentLoader.item.implicitHeight || contentLoader.item.height) : 0
                    when: contentLoader.item
                }
                Binding {
                    target: root
                    property: "currentLoader"
                    value: contentLoader
                    when: index === root.currentIndex && contentLoader.status === Loader.Ready
                }
            }

            ShaderEffectSource {
                id: effectSource
                width: contentLoader.implicitWidth
                height: contentLoader.implicitHeight
                sourceItem: contentLoader
                hideSource: true
                live: true

                scale: index === root.currentIndex ? 1 : 0
                Behavior on scale {
                    NumberAnimation {
                        duration: root.fadeDuration
                        easing.type: Easing.OutQuart
                    }
                }
            }

            FastBlur {
                width: contentLoader.implicitWidth
                height: contentLoader.implicitHeight
                source: effectSource
                radius: index === root.currentIndex ? 0 : 40

                Behavior on radius {
                    NumberAnimation {
                        duration: root.fadeDuration
                        easing.type: Easing.OutQuart
                    }
                }
            }

            opacity: index === root.currentIndex ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: root.fadeDuration
                    easing.type: Easing.OutQuart
                }
            }
        }
    }
}
