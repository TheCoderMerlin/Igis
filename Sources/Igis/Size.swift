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

public struct Size : Equatable {
    public private (set) var width : Int
    public private (set) var height : Int

    public init() {
        self.width = 0
        self.height = 0
    }

    public init(width:Int, height:Int) {
        self.width = width
        self.height = height
    }

    public mutating func enlargeBy(changeWidth:Int, changeHeight:Int) {
        width += changeWidth
        height += changeHeight
    }

    public mutating func enlargeWidthBy(change:Int) {
        width += change
    }

    public mutating func enlargeHeightBy(change:Int) {
        height += change
    }

    public mutating func changeTo(width:Int, height:Int) {
        self.width = width
        self.height = height
    }

    public var center : Point {
        Point(x: width / 2, y: height / 2)
    }    

    static public func == (lhs:Size, rhs:Size) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
    
}
