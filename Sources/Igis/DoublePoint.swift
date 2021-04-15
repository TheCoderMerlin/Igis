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

import Foundation
  
/// A `DoublePoint` represents a location in a two-dimensional plane.
public struct DoublePoint : Equatable {
    /// The coordinate along the x-axis
    public var x : Double
    /// The coordinate along the y-axis
    public var y : Double

    /// The point (x:0.0, y:0.0)
    static public let zero = DoublePoint(x: 0.0, y: 0.0)

    /// Creates a new `DoublePoint` located at (x:0, y:0)
    public init() {
        self.x = 0.0
        self.y = 0.0
    }
    
    /// Creates a new `DoublePoint` from the specified coordinates
    /// - Parameters:
    ///   - x: The x coordinate
    ///   - y: The y coordinate
    public init(x:Double, y:Double) {
        self.x = x
        self.y = y
    }

    /// Creates a new `DoublePoint` from the specified coordinates
    /// - Parameters:
    ///   - x: The x coordinate
    ///   - y: The y coordinate
    public init(x:Int, y:Int) {
        self.x = Double(x)
        self.y = Double(y)
    }

    /// Creates a new `DoublePoint` from the specified `Point`
    /// - Parameters:
    ///   - point: The source of the x, y coordinates
    public init(_ point:Point) {
        self.x = Double(point.x)
        self.y = Double(point.y)
    }

    /// Calculates the square of the distance between this point and another
    /// - Parameters:
    ///   - target: The target point to which to calculate the distance
    /// - Returns: The square of the distance to a target point
    public func distanceSquared(target:DoublePoint) -> Double {
        let xDistance = target.x - x
        let xDistanceSquared = xDistance * xDistance
        
        let yDistance = target.y - y
        let yDistanceSquared = yDistance * yDistance

        return xDistanceSquared + yDistanceSquared
    }

    /// Calculates the distance between this point and another
    /// - Parameters:
    ///   - target: The target point to which to calculate the distance
    /// - Returns: The distance to a target point
    public func distance(target:DoublePoint) -> Double {
        return sqrt(distanceSquared(target:target))
    }
    
    /// Converts an array of `Point`s to an array of `DoublePoint`s
    static public func DoublePoints(_ points: [Point]) -> [DoublePoint] {
        return points.map {DoublePoint($0)}
    }

    /// Equivalence operator for two `DoublePoint`s
    static public func == (lhs:DoublePoint, rhs:DoublePoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    /// Addition operator for two `DoublePoint`s
    static public func + (left: DoublePoint, right: DoublePoint) -> DoublePoint {
        return DoublePoint(x: left.x + right.x, y: left.y + right.y)
    }

    /// Compound addition operator for two `DoublePoint`s
    static public func += (left: inout DoublePoint, right: DoublePoint) {
        left = left + right
    }

    /// Negation operator for a `DoublePoint`
    static public prefix func - (doublePoint: DoublePoint) -> DoublePoint {
        return DoublePoint(x: -doublePoint.x, y: -doublePoint.y)
    }

    /// Subtraction operator for two `DoublePoint`s
    static public func - (left: DoublePoint, right: DoublePoint) -> DoublePoint {
        return left + -right
    }

    /// Compound subtration operator for two `DoublePoint`s
    static public func -= (left: inout DoublePoint, right: DoublePoint) {
        left = left - right
    }
}
