import QtQuick
import QtQuick.Shapes
import qs.config

Shape {
    id: root
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    property real radius: 20
    readonly property bool flatten: height < radius * 2
    readonly property real radiusX: radius
    readonly property real radiusY: flatten ? height / 2 : Math.min(radius, height / 2)

    ShapePath {
        strokeWidth: 0
        fillColor: Config.colors.base

        PathArc {
            x: root.radiusX
            y: root.radiusY
            radiusX: root.radiusX
            radiusY: root.radiusY
        }
        PathLine {
            x: root.radiusX
            y: Math.max(root.height - root.radiusY, root.height / 2)
        }
        PathArc {
            x: root.radiusX * 2
            y: root.height
            radiusX: root.radiusX
            radiusY: root.radiusY
            direction: PathArc.Counterclockwise
        }
        PathLine {
            x: root.width - root.radiusX * 2
            y: root.height
        }
        PathArc {
            x: root.width - root.radiusX
            y: Math.max(root.height - root.radiusY, root.height / 2)
            radiusX: root.radiusX
            radiusY: root.radiusY
            direction: PathArc.Counterclockwise
        }
        PathLine {
            x: root.width - root.radiusX
            y: root.radiusY
        }
        PathArc {
            x: root.width
            radiusX: root.radiusX
            radiusY: root.radiusY
        }
    }
}
