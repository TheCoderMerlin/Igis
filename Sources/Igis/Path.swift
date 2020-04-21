/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018-2020 Tango Golf Digital, LLC
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/


public class Path : CanvasObject {

    private enum Action {
        case beginPath
        case moveTo(point:Point)
        case lineTo(point:Point)
        case rect(rect:Rect)
        case arc(center:Point, radius:Int, startAngle:Double, endAngle:Double, antiClockwise:Bool)
        case arcTo(controlPoint1:Point, controlPoint2:Point, radius:Int)
        case quadraticCurveTo(controlPoint:Point, endPoint:Point)
        case bezierCurveTo(controlPoint1:Point, controlPoint2:Point, endPoint:Point)
        case closePath
    }
    private var actions = [Action]()
    public var fillMode : FillMode

    internal func begin() {
        actions.append(.beginPath)
    }

    
    public init(fillMode:FillMode = .stroke) {
        self.fillMode = fillMode
        
        super.init()
        
        begin()
    }

    // Creates a path by moving to the first point in the array,
    // then drawing lines to each subsequent point,
    // and then closing the path
    public convenience init(points:[Point], fillMode:FillMode = .stroke) {
        self.init(fillMode:fillMode)

        precondition(points.count >= 2, "Initializing a Path with an array of points requires at least two points")
        var pointsQueue = points
        moveTo(pointsQueue[0])
        pointsQueue.removeFirst()
        linesTo(pointsQueue)

        close()
    }

    // Creates a path for a rounded rectangle and then closes the path
    public convenience init(rect:Rect, radius:Int, fillMode:FillMode = .stroke) {
        self.init(fillMode:fillMode)

        moveTo(Point(x:rect.left + radius, y:rect.top))
        lineTo(Point(x:rect.right - radius, y:rect.top))
        quadraticCurveTo(controlPoint:rect.topRight, endPoint:Point(x:rect.right, y:rect.top + radius))
        lineTo(Point(x:rect.right, y:rect.bottom - radius))
        quadraticCurveTo(controlPoint:rect.bottomRight, endPoint:Point(x:rect.right - radius, y:rect.bottom))
        lineTo(Point(x:rect.left + radius, y:rect.bottom))
        quadraticCurveTo(controlPoint:rect.bottomLeft, endPoint:Point(x:rect.left, y:rect.bottom - radius))
        lineTo(Point(x:rect.left, y:rect.top + radius))
        quadraticCurveTo(controlPoint:rect.topLeft, endPoint:Point(x:rect.left + radius, y:rect.top))
        
        close()
    }

    public func moveTo(_ point:Point) {
        actions.append(.moveTo(point:point))
    }

    public func lineTo(_ point:Point) {
        actions.append(.lineTo(point:point))
    }

    // Appends to an existing path by executing lineTo to each point specified
    // in the array
    public func linesTo(_ points:[Point]) {
        var pointsQueue = points
        while let point = pointsQueue.first {
            lineTo(point)
            pointsQueue.removeFirst()
        }
    }

    public func rect(_ rect:Rect) {
        actions.append(.rect(rect:rect))
    }

    public func arc(center:Point, radius:Int, startAngle:Double=0.0, endAngle:Double=2.0*Double.pi,
                    antiClockwise:Bool = false) {
        actions.append(.arc(center:center, radius:radius, startAngle:startAngle, endAngle:endAngle, antiClockwise:antiClockwise))
    }

    public func arcTo(controlPoint1:Point, controlPoint2:Point, radius:Int) {
        actions.append(.arcTo(controlPoint1:controlPoint1, controlPoint2:controlPoint2, radius:radius))
    }

    public func quadraticCurveTo(controlPoint:Point, endPoint:Point) {
        actions.append(.quadraticCurveTo(controlPoint:controlPoint, endPoint:endPoint))
    }

    public func bezierCurveTo(controlPoint1:Point, controlPoint2:Point, endPoint:Point) {
        actions.append(.bezierCurveTo(controlPoint1:controlPoint1, controlPoint2:controlPoint2, endPoint:endPoint))
    }


    public func close() {
        actions.append(.closePath)
    }

    internal override func canvasCommand() -> String {
        var actionStrings = [String]()

        for action in actions {
            switch (action) {
            case .beginPath:
                actionStrings.append("beginPath")
            case .moveTo(let point):
                actionStrings.append("moveTo|\(point.x)|\(point.y)")
            case .lineTo(let point):
                actionStrings.append("lineTo|\(point.x)|\(point.y)")
            case .rect(let rect):
                actionStrings.append("rect|\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)")
            case .arc(let center, let radius, let startAngle, let endAngle, let antiClockwise):
                actionStrings.append("arc|\(center.x)|\(center.y)|\(radius)|\(startAngle)|\(endAngle)|\(antiClockwise)")
            case .arcTo(let controlPoint1, let controlPoint2, let radius):
                actionStrings.append("arcTo|\(controlPoint1.x)|\(controlPoint1.y)|\(controlPoint2.x)|\(controlPoint2.y)|\(radius)")
            case .quadraticCurveTo(let controlPoint, let endPoint):
                actionStrings.append("quadraticCurveTo|\(controlPoint.x)|\(controlPoint.y)|\(endPoint.x)|\(endPoint.y)")
            case .bezierCurveTo(let controlPoint1, let controlPoint2, let endPoint):
                actionStrings.append("bezierCurveTo|\(controlPoint1.x)|\(controlPoint1.y)|\(controlPoint2.x)|\(controlPoint2.y)|\(endPoint.x)|\(endPoint.y)")
            case .closePath:
                actionStrings.append("closePath")
            }
        }

        var commands = actionStrings.joined(separator:"||")
        switch fillMode {
            case .stroke:
                commands += "||stroke"
            case .fill, .clear:
                commands += "||fill"
            case .fillAndStroke:
                commands += "||fill||stroke"
        }

        return commands

    }
}
