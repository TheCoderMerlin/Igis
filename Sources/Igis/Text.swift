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
    public enum Alignment {
        case left
        case center
        case right

        case start
        case end
    }
    public enum Baseline {
        case top
        case hanging
        case middle
        case alphabetic
        case ideographic
        case bottom
    }
    public var location : Point
    public var text : String
    public var fillMode : FillMode

    public var font : String?
    public var alignment : Alignment? = nil
    public var baseline : Baseline? = nil
    
    public init(location:Point, text:String, fillMode:FillMode = .fill) {
        self.location = location
        self.text = text
        self.fillMode = fillMode
    }
    
    internal override func canvasCommand() -> String {
        var commands = String()
        
        if let font = font {
            commands += "font|\(font)||"
        }

        if let alignment = alignment {
            commands += "processTextAlign|"
            switch alignment {
            case .left:
                commands += "left"
            case .center:
                commands += "center"
            case .right:
                commands += "right"
            case .start:
                commands += "start"
            case .end:
                commands += "end"
            }
            commands += "||"
        }

        if let baseline = baseline {
            commands += "processTextBaseline|"
            switch baseline {
            case .top:
                commands += "top"
            case .hanging:
                commands += "hanging"
            case .middle:
                commands += "middle"
            case .alphabetic:
                commands += "alphabetic"
            case .ideographic:
                commands += "ideographic"
            case .bottom:
                commands += "bottom"
            }
            commands += "||"
        }


        if (text.count > 0) {
            switch fillMode {
            case .stroke:
                commands += "strokeText|\(text)|\(location.x)|\(location.y)"
            case .fill, .clear:
                commands += "fillText|\(text)|\(location.x)|\(location.y)"
            case .fillAndStroke:
                commands += "fillText|\(text)|\(location.x)|\(location.y)||"
                commands += "strokeText|\(text)|\(location.x)|\(location.y)"
            }
        }
        return commands
    }
}
