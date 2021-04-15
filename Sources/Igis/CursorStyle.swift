/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018-2020 CoderMerlin.com
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

public class CursorStyle : CanvasObject {
    public enum Style : String {
        // Defaults
        case initial         = "initial"
        case auto            = "auto"
        case defaultCursor   = "default"

        // None
        case none            = "none"

        // Waiting
        case progress        = "progress"
        case wait            = "wait"

        // Pointer types
        case pointer         = "pointer"
        case crosshair       = "crosshair"
        case help            = "help"
        case contextMenu     = "context-menu"
        case alias           = "alias"

        // Text and cells
        case text            = "text"
        case textVertical    = "vertical-text"
        case cell            = "cell"

        // Movement and dragging
        case notAllowed      = "not-allowed"
        case noDrop          = "no-drop"

        case allScroll       = "all-scroll"
        
        case move            = "move"
        case copy            = "copy"

        case resizeNorth     = "n-resize"
        case resizeNorthEast = "ne-resize"
        case resizeEast      = "e-resize"
        case resizeSouthEast = "se-resize"
        case resizeSouth     = "s-resize"
        case resizeSouthWest = "sw-resize"
        case resizeWest      = "w-resize"
        case resizeNorthWest = "nw-resize"

        case resizeRow       = "row-resize"
        case resizeColumn    = "col-resize"

        // Zooming
        case zoomIn          = "zoom-in"
        case zoomOut         = "zoom-out"
    }
    private let style : Style

    public init(style:Style) {
        self.style = style
    }

    internal override func canvasCommand() -> String {
        let commands = "cursorStyle|\(style.rawValue)"
        return commands
    }
}
