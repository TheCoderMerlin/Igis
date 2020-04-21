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

/// A `Point` represents a location in a two-dimensional plane.
public struct Point : Equatable {
    /// The coordinate along the x-axis
    public var x : Int
    /// The coordinate along the y-axis
    public var y : Int

    /// The point (x:0, y:0)
    static public let zero = Point(x: 0, y: 0)

    /// Creates a new `Point` located at (x:0, y:0)
    public init() {
        self.x = 0
        self.y = 0
    }

    /// Creates a new `Point` from the specified coordinates
    /// - Parameters:
    ///   - x: The x coordinate
    ///   - y: The y coordinate
    public init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }

    /// Creates a new `Point` from the specified `DoublePoint`
    /// - Parameters:
    ///   - doublePoint: The source of the new coordinates
    public init(_ doublePoint:DoublePoint) {
        self.x = Int(doublePoint.x)
        self.y = Int(doublePoint.y)
    }

    /// Calculates the square of the distance between this point and another
    /// - Parameters:
    ///   - target: The target point to which to calculate the distance
    /// - Returns: The square of the distance to a target point
    public func distanceSquared(to target:Point) -> Int {
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
    public func distance(to target: Point) -> Double {
        return sqrt(Double(distanceSquared(to:target)))
    }

    /// Converts an array of `DoublePoint`s to an array of `Point`s
    static public func Points(_ doublePoints: [DoublePoint]) -> [Point] {
        return doublePoints.map {Point($0)}
    }

    /// Equivalence operator for two `Point`s
    static public func == (left: Point, right: Point) -> Bool {
        return left.x == right.x && left.y == right.y
    }

    /// Addition operator for two `Point`s
    static public func + (left: Point, right: Point) -> Point {
        return Point(x: left.x + right.x, y: left.y + right.y)
    }

    /// Compound addition operator for two `Point`s
    static public func += (left: inout Point, right: Point) {
        left = left + right
    }

    /// Negation operator for a `Point`
    static public prefix func - (point:Point) -> Point {
        return Point(x: -point.x, y: -point.y)
    }

    /// Subtraction operator for two `Point`s
    static public func - (left: Point, right: Point) -> Point {
        return left + -right
    }

    /// Compound subtration operator for two `Point`s
    static public func -= (left: inout Point, right: Point) {
        left = left - right
    }
}

