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

public class Lines : CanvasObject {

    private enum PointAction {
        case moveTo(point:Point)
        case lineTo(point:Point)
    }
    private var pointActions = [PointAction]()

    public init(from:Point, to:Point) {
        pointActions.append(.moveTo(point:from))
        pointActions.append(.lineTo(point:to))
    }

    public func moveTo(_ point:Point) {
        pointActions.append(.moveTo(point:point))
    }
    
    public func lineTo(_ point:Point) {
        pointActions.append(.lineTo(point:point))
    }

    internal override func canvasCommand() -> String {
        var pointActionStrings = [String]()
        
        for pointAction in pointActions {
            switch pointAction {
            case .moveTo(let point):
                pointActionStrings.append("moveTo|\(point.x)|\(point.y)")
            case .lineTo(let point):
                pointActionStrings.append("lineTo|\(point.x)|\(point.y)")
            }
        }

        var commands = String()
        commands += "beginPath||"
        commands += pointActionStrings.joined(separator:"||")
        commands += "||stroke"
        return commands
    }
    
}
