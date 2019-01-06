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

public class Rectangle : CanvasObject {
    public var rect : Rect
    public var fillMode : FillMode

    public init(rect:Rect, fillMode:FillMode = .fill) {
        self.rect = rect
        self.fillMode = fillMode
    }

    internal override func canvasCommand() -> String {
        var commands = String()
        switch fillMode {
            case .stroke:
                commands += "strokeRect|\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)"
            case .fill:
                commands += "fillRect|\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)"
            case .fillAndStroke:
                commands += "fillRect|\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)||"
                commands += "strokeRect|\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)"
            case .clear:
                commands += "clearRect|\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)"
        }
        return commands
    }
}
