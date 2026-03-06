import QtQuick

Canvas {
    id: canvas
    width: radius
    height: radius
    
    property int radius: 20
    property color color: "white"
    property int position: InvertedCorner.TopLeft
    
    readonly property int topLeft: 0
    readonly property int topRight: 1
    readonly property int bottomRight: 2
    readonly property int bottomLeft: 3
    
    onRadiusChanged: requestPaint()
    onColorChanged: requestPaint()
    onPositionChanged: requestPaint()
    
    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = color
        
        ctx.beginPath()
        
        if (position === topLeft) {
            ctx.moveTo(0, 0)
            ctx.lineTo(0, radius)
            ctx.arc(radius, radius, radius, Math.PI, 1.5 * Math.PI, false)
            ctx.lineTo(0, 0)
        } else if (position === topRight) {
            ctx.moveTo(0, 0)
            ctx.lineTo(radius, 0)
            ctx.arc(0, radius, radius, 1.5 * Math.PI, 2 * Math.PI, false)
            ctx.lineTo(0, 0)
        } else if (position === bottomRight) {
            ctx.moveTo(radius, 0)
            ctx.lineTo(radius, radius)
            ctx.arc(0, 0, radius, 0, 0.5 * Math.PI, false)
            ctx.lineTo(radius, 0)
        } else if (position === bottomLeft) {
            ctx.moveTo(0, 0)
            ctx.lineTo(0, radius)
            ctx.lineTo(radius, radius)
            ctx.arc(radius, 0, radius, 0.5 * Math.PI, Math.PI, false)
            ctx.lineTo(0, 0)
        }
        
        ctx.closePath()
        ctx.fill()
    }
}
