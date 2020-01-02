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

public struct Point : Equatable {
    public private (set) var x : Int
    public private (set) var y : Int

    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }

    public mutating func moveBy(offsetX:Int, offsetY:Int) {
        x += offsetX
        y += offsetY
    }

    public mutating func moveBy(offset:Point) {
        x += offset.x
        y += offset.y
    }

    public mutating func moveXBy(offset:Int) {
        x += offset
    }

    public mutating func moveYBy(offset:Int) {
        y += offset
    }

    public mutating func moveTo(x:Int, y:Int) {
        self.x = x
        self.y = y
    }

    public mutating func moveTo(_ point:Point) {
        self = point
    }

    static public func == (lhs:Point, rhs:Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

