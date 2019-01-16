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

import Foundation  
  
public class Image : CanvasIdentifiedObject {
    public let sourceURL : URL
    public var topLeft : Point

    public init(sourceURL:URL, topLeft:Point = Point(x:0, y:0)) {
        self.sourceURL = sourceURL
        self.topLeft = topLeft
    }

    internal override func canvasCommand() -> String {
        if !isLoaded {
            print("WARNING: canvasCommand requested on image not yet loaded. ID: \(id.uuidString).")
        }
        let commands = "drawImage|\(id.uuidString)|\(topLeft.x)|\(topLeft.y)"
        return commands
    }

    internal override func setupCommand() -> String {
        let commands = "createImage|\(id.uuidString)|\(sourceURL.absoluteString)"
        return commands
    }

    
}
