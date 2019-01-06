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

public struct DoublePoint {
    public private (set) var x : Double
    public private (set) var y : Double
    
    public init(x:Double, y:Double) {
        self.x = x
        self.y = y
    }

    public mutating func moveBy(offsetX:Double, offsetY:Double) {
        x += offsetX
        y += offsetY
    }

    public mutating func moveTo(x:Double, y:Double) {
        self.x = x
        self.y = y
    }
}
