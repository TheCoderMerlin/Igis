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

public class Text : CanvasObject {
    public var location : Point
    public var text : String
    public var font : String?
    public var fillMode : FillMode
    
    public init(location:Point, text:String, font:String?=nil, fillMode:FillMode = .fill) {
        self.location = location
        self.text = text
        self.font = font
        self.fillMode = fillMode
    }
    
    internal override func canvasCommand() -> String {
        var commands = String()
        if font != nil {
            commands += "font|\(font!)||"
        }
        switch fillMode {
        case .stroke:
            commands += "strokeText|\(text)|\(location.x)|\(location.y)"
        case .fill, .clear:
            commands += "fillText|\(text)|\(location.x)|\(location.y)"
        case .fillAndStroke:
            commands += "fillText|\(text)|\(location.x)|\(location.y)||"
            commands += "strokeText|\(text)|\(location.x)|\(location.y)"
        }
        return commands
    }
}
