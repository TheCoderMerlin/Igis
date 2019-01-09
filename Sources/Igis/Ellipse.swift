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

public class Ellipse : CanvasObject {
    public var center : Point
    public var radiusX : Int
    public var radiusY : Int
    public var rotation : Double // radians
    public var startAngle : Double
    public var endAngle : Double
    public var antiClockwise : Bool
    public var fillMode : FillMode

    public init(center:Point, radiusX:Int, radiusY:Int, rotation:Double=0.0, startAngle:Double=0.0, endAngle:Double=2.0*Double.pi,
                antiClockwise:Bool=false, fillMode:FillMode = .stroke) {
        self.center = center
        self.radiusX = radiusX
        self.radiusY = radiusY
        self.rotation = rotation
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.antiClockwise = antiClockwise
        self.fillMode = fillMode
    }
    
    internal override func canvasCommand() -> String {
        var commands = String()
        commands += "beginPath||"
        commands += "ellipse|\(center.x)|\(center.y)|\(radiusX)|\(radiusY)|\(rotation)|\(startAngle)|\(endAngle)|\(antiClockwise)||"

        switch fillMode {
        case .stroke:
            commands += "stroke"
        case .fill, .clear:
            commands += "fill"
        case .fillAndStroke:
            commands += "fill||stroke"
        }

        return commands
    }
}
