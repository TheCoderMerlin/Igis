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

public struct Rect {
    public var topLeft : Point
    public var size : Size

    public var left : Int {
        return topLeft.x
    }

    public var top : Int {
        return topLeft.y
    }

    public var right : Int {
        return topLeft.x + size.width
    }

    public var bottom : Int {
        return topLeft.y + size.height
    }

    public init(topLeft:Point, size:Size) {
        self.topLeft = topLeft
        self.size = size
    }

    public init(bottomLeft:Point, size:Size) {
        self.topLeft = Point(x:bottomLeft.x, y:bottomLeft.y-size.height)
        self.size = size
    }

    public init(topRight:Point, size:Size) {
        self.topLeft = Point(x:topRight.x-size.width, y:topRight.y)
        self.size = size
    }

    public init(bottomRight:Point, size:Size) {
        self.topLeft = Point(x:bottomRight.x-size.width, y:bottomRight.y-size.height)
        self.size = size
    }

}
