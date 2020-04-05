/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018-2020 Tango Golf Digital, LLC
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
  
public struct DoublePoint {
    public private (set) var x : Double
    public private (set) var y : Double


    public init() {
        self.x = 0.0
        self.y = 0.0
    }
    
    public init(x:Double, y:Double) {
        self.x = x
        self.y = y
    }

    public init(point:Point) {
        self.x = Double(point.x)
        self.y = Double(point.y)
    }

    public mutating func moveBy(offsetX:Double, offsetY:Double) {
        x += offsetX
        y += offsetY
    }

    public mutating func moveBy(offset:DoublePoint) {
        x += offset.x
        y += offset.y
    }

    public mutating func moveXBy(offset:Double) {
        x += offset
    }

    public mutating func moveYBy(offset:Double) {
        y += offset
    }

    public mutating func moveTo(x:Double, y:Double) {
        self.x = x
        self.y = y
    }
    
    public mutating func moveTo(_ point:DoublePoint) {
        self = point
    }

    public func negated() -> DoublePoint {
        return DoublePoint(x:-x, y:-y)
    }

    public func distanceSquared(target:DoublePoint) -> Double {
        let xDistance = target.x - x
        let xDistanceSquared = xDistance * xDistance
        
        let yDistance = target.y - y
        let yDistanceSquared = yDistance * yDistance

        return xDistanceSquared + yDistanceSquared
    }

    public func distance(target:DoublePoint) -> Double {
        return sqrt(distanceSquared(target:target))
    }

    
    static public func DoublePoints(points:[Point]) -> [DoublePoint] {
        return points.map {DoublePoint(point:$0)}
    }

    static public func == (lhs:DoublePoint, rhs:DoublePoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

}
