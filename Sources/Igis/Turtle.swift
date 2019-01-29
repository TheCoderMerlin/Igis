/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018 Tango Golf Digital, LLC
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

/* Reference: http://www.mit.edu/~hlb/MA562/commands.html
The center of the graphics window is turtle location [0 0].  Positive
X is to the right; positive Y is up.  Headings (angles) are measured
in degrees clockwise from the positive Y axis.  (This differs from the
common mathematical convention of measuring angles counterclockwise
from the positive X axis.)  
*/

import Foundation

public class Turtle : CanvasObject {
    private let canvasSize : Size
    private let canvasCenter : DoublePoint
    private var actions : [Action]
    private enum Action {
        case forward(steps:Int)
        case backward(steps:Int)
        case left(degrees:Double)   // degrees counter-clockwise
        case right(degrees:Double)  // degrees clockwise

        case penUp
        case penDown
        case penColor(color:Color)
        case penWidth(width:Int)

        case push
        case pop
        
        case home
    }

    public init(canvasSize:Size)
    {
        self.canvasSize = canvasSize
        self.canvasCenter = DoublePoint(x:Double(canvasSize.width)/2.0, y:Double(canvasSize.height)/2.0)
        actions = [Action]()
    }

    public func forward(steps:Int) {
        actions.append(.forward(steps:steps))
    }

    public func backward(steps:Int) {
        actions.append(.backward(steps:steps))
    }

    public func left(degrees:Double) {
        actions.append(.left(degrees:degrees))
    }

    public func right(degrees:Double) {
        actions.append(.right(degrees:degrees))
    }

    public func penUp() {
        actions.append(.penUp)
    }

    public func penDown() {
        actions.append(.penDown)
    }

    public func penColor(color:Color) {
        actions.append(.penColor(color:color))
    }

    public func penWidth(width:Int) {
        actions.append(.penWidth(width:width))
    }

    public func push() {
        actions.append(.push)
    }

    public func pop() {
        actions.append(.pop)
    }

    public func home() {
        actions.append(.home)
    }

    internal override func canvasCommand() -> String {
        var actionStrings = [String]()
        var turtleLocation = DoublePoint(x:0.0, y:0.0) // We use doubles for tracking location to avoid accumulated errors
        var turtleAngle = 0.0 // Start pointing north.  (degrees clockwise from north)
        var turtleColor : Color?
        var turtleWidth : Int?
        var isPenDown = true
        var isPathOpen = false

        struct State {
            let location : DoublePoint
            let angle : Double
            let color : Color?
            let width : Int?
        }
        var stateStack = [State]()

        func openPath() {
            precondition(!isPathOpen, "Turtle.canvasCommand.openPath: Path is already open.")
            actionStrings.append("beginPath")
            isPathOpen = true
            moveTo(location:turtleLocation) // Anytime we begin a path we need to move to the current location
        }
        func closePath() {
            precondition(isPathOpen, "Turtle.canvasCommand.strokePath: Path isn't open.")
            actionStrings.append("stroke")
            isPathOpen = false
        }
        func ensurePathIsOpen() {
            if !isPathOpen {
                openPath()
            }
        }
        func ensurePathIsClosed() {
            if isPathOpen {
                closePath()
            }
        }
        func canvasLocation(location:DoublePoint) -> Point {
            // 0,0 is screen center
            // +X is to the right
            // +Y is to the top
            let x = Int((canvasCenter.x + location.x).rounded())
            let y = Int((canvasCenter.y - location.y).rounded())
            return Point(x:x, y:y)
        }
        func nextTurtleLocation(steps:Int, angle:Double) -> DoublePoint {
            // Calculate the next location given the current angle
            // Note: Angle is in degrees with 0 degrees at north rotating clockwise
            let angleShiftedToEast = 90.0 - angle
            let angleInRadians = angleShiftedToEast * Double.pi / 180.0
            let xDistance = Double(steps) * cos(angleInRadians)
            let yDistance = Double(steps) * sin(angleInRadians)
            let newX = turtleLocation.x + xDistance
            let newY = turtleLocation.y + yDistance
            return DoublePoint(x:newX, y:newY)
        }
        func moveTo(location:DoublePoint) {
            precondition(isPathOpen, "Turtle.canvasCommand.moveTo: Path isn't open.")
            let translatedLocation = canvasLocation(location:location)
            actionStrings.append("moveTo|\(translatedLocation.x)|\(translatedLocation.y)")
        }
        func lineTo(location:DoublePoint) {
            precondition(isPathOpen, "Turtle.canvasCommand.moveTo: Path isn't open.")
            let translatedLocation = canvasLocation(location:location)
            actionStrings.append("lineTo|\(translatedLocation.x)|\(translatedLocation.y)")
        }
        func setColor(color:Color) {
            ensurePathIsClosed()
            turtleColor = color // Save in case of push
            let strokeStyle = StrokeStyle(color:color)
            actionStrings.append(strokeStyle.canvasCommand())
            ensurePathIsOpen()
        }
        func setWidth(width:Int) {
            ensurePathIsClosed()
            turtleWidth = width // Save in case of push
            let lineWidth = LineWidth(width:width)
            actionStrings.append(lineWidth.canvasCommand())
            ensurePathIsOpen()
        }

        func push() {
            stateStack.append(State(location:turtleLocation, angle:turtleAngle, color:turtleColor, width:turtleWidth))
        }

        func pop() {
            if let state = stateStack.popLast() {
                turtleLocation = state.location
                moveTo(location:turtleLocation)
                turtleAngle = state.angle
                if let color = state.color {
                    setColor(color:color)
                }
                if let width = state.width {
                    setWidth(width:width)
                }
            }
        }
        

        // Start at home
        ensurePathIsOpen()

        for action in actions {
            switch action {
            case .forward(let steps):
                turtleLocation = nextTurtleLocation(steps:steps, angle:turtleAngle)
                if isPenDown {
                    lineTo(location:turtleLocation)
                } else {
                    moveTo(location:turtleLocation)
                }
            case .backward(let steps):
                turtleLocation = nextTurtleLocation(steps:steps, angle:turtleAngle+180.0)
                if isPenDown {
                    lineTo(location:turtleLocation)
                } else {
                    moveTo(location:turtleLocation)
                }
            case .left(let degrees):
                turtleAngle -= degrees
            case .right(let degrees):
                turtleAngle += degrees
            case .penUp:
                isPenDown = false
            case .penDown:
                isPenDown = true
            case .penColor(let color):
                setColor(color:color)
            case .penWidth(let width):
                setWidth(width:width)
            case .push:
                push()
            case .pop:
                pop()
            case .home:
                turtleLocation = DoublePoint(x:0.0, y:0.0)
                if isPenDown {
                    lineTo(location:turtleLocation)
                } else {
                    moveTo(location:turtleLocation)
                }
                turtleAngle = 0.0
            } // switch action
        }  // for action

        // All done
        ensurePathIsClosed()

        return actionStrings.joined(separator:"||")
    } // func canvasCommand
} // class Turtle
