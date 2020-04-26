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

/// A `Size` represents dimensions in a two-dimensional plane.
public struct Size : Equatable {
    /// The x-axis extent
    public var width : Int

    /// The y-axis extent 
    public var height : Int

    /// The size (width:0, height:0)
    static public let zero = Size(width: 0, height: 0)

    /// Create a new `Size` of (width:0, height:0)
    public init() {
        self.width = 0
        self.height = 0
    }

    /// Creates a new `Size` from the specified parameters
    /// - Parameters:
    ///   - width: The x-axis extent
    ///   - height: The y-axis extent
    public init(width:Int, height:Int) {
        self.width = width
        self.height = height
    }

    /// Enlarges both dimenisions by the amount specified
    /// (negative numbers reduce the dimensions)
    /// - Parameters:
    ///   - change: The amount by which to increase both dimensions
    public mutating func enlarge(by change:Int) {
        width += change
        height += change
    }

    /// The `Point` located at the center between the origin (x:0, y:0)
    /// and the point located at size
    public var center : Point {
        Point(x: width / 2, y: height / 2)
    }
    
    /// Calculates a new Size of certain percentage between this Size and another
    /// - Parameters:
    ///   - target: The target size to which to calculate the new Size between
    ///   - percent: Value between 0 and 1 representing percentage
    /// - Returns: A new size of percent between this size and a target size
    public func lerp(to target:Size, percent:Double) -> Size {
        return Size(width:width+Int(Double(target.width-width)*percent), height:height+Int(Double(target.height-height)*percent))
    }

    /// Equivalence operator for two `Size`s
    static public func == (lhs:Size, rhs:Size) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
    
}
