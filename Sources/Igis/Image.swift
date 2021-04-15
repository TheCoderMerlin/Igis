/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018 CoderMerlin.com
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

    public enum RenderMode {
        case destinationPoint(_ topLeft:Point)
        case destinationRect(_ rect:Rect)
        case sourceAndDestination(sourceRect:Rect, destinationRect:Rect)
    }
    public var renderMode : RenderMode

    public init(sourceURL:URL, topLeft:Point = Point(x:0, y:0)) {
        self.sourceURL = sourceURL
        self.renderMode = .destinationPoint(topLeft)
    }

    internal override func canvasCommand() -> String {
        if !isReady {
            print("WARNING: canvasCommand requested on image not yet ready. ID: \(id.uuidString).")
        }
        var commands : String =  "drawImage|\(id.uuidString)|"
        switch renderMode {
        case .destinationPoint(let topLeft):
            commands += "\(topLeft.x)|\(topLeft.y)"
        case .destinationRect(let rect):
            commands += "\(rect.topLeft.x)|\(rect.topLeft.y)|\(rect.size.width)|\(rect.size.height)"
        case .sourceAndDestination(let sourceRect, let destinationRect):
            commands += "\(sourceRect.topLeft.x)|\(sourceRect.topLeft.y)|\(sourceRect.size.width)|\(sourceRect.size.height)|" +
              "\(destinationRect.topLeft.x)|\(destinationRect.topLeft.y)|\(destinationRect.size.width)|\(destinationRect.size.height)"
        }
        
        return commands
    }

    internal override func setupCommand() -> String {
        let commands = "createImage|\(id.uuidString)|\(sourceURL.absoluteString)"
        return commands
    }

    
}
