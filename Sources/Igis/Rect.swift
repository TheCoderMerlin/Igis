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

/// A `Rect` represents a rectangle in a two-dimensional plane.  
public struct Rect : Equatable {
    public var topLeft : Point
    public var size : Size

    /// The rect at the origin with zero size
    static public let zero = Rect(topLeft:Point(), size:Size())

    /// The coordinate along the x-axis at the left of rect
    /// This value is modifiable and will alter only the left coordinate,
    /// thus, the size will change
    public var left : Int {
        get {
            return topLeft.x
        }
        set (newLeft) {
            let delta = newLeft - topLeft.x
            topLeft.x += delta
            size.width -= delta
        }
    }

    /// The coordinate along the y-axis at the top of rect
    /// This value is modifiable and will alter only the top coordinate,
    /// thus, the size will change
    public var top : Int {
        get {
            return topLeft.y
        }
        set (newTop) {
            let delta = newTop - topLeft.y
            topLeft.y += delta
            size.height -= delta
        }
    }

    /// The coordinate along the x-axis at the right of rect
    /// This value is modifiable and will alter only the right coordinate,
    /// thus, the size will change
    public var right : Int {
        get {
            return topLeft.x + size.width
        }
        set (newRight) {
            let delta = newRight - (topLeft.x + size.width)
            size.width += delta
        }
    }

    /// The coordinate along the y-axis at the bottom of rect
    /// This value is modifiable and will alter only the bottom coordinate,
    /// thus, the size will change
    public var bottom : Int {
        get {
            return topLeft.y + size.height
        }
        set (newBottom) {
            let delta = newBottom - (topLeft.y + size.height)
            size.height += delta
        }
    }


    /// The width of the rectangle
    /// This value is modifiable and will alter the right coodinate
    public var width : Int {
        get {
            return size.width
        }
        set (newWidth) {
            size.width = newWidth
        }
    }


    /// The height of the rectangle
    /// This value is modifiable and will alter the bottom coordinate
    public var height : Int {
        get {
            return size.height
        }
        set (newHeight) {
            size.height = newHeight
        }
    }

    public var topRight : Point {
        get {
            return Point(x:right, y:top)
        }
        set (newTopRight) {
            right = newTopRight.x
            top   = newTopRight.y
        }
    }

    public var bottomLeft : Point {
        get {
            return Point(x:left, y:bottom)
        }
        set (newBottomLeft) {
            left    = newBottomLeft.x
            bottom  = newBottomLeft.y
        }
    }

    public var bottomRight : Point {
        get {
            return Point(x:right, y:bottom)
        }
        set (newBottomRight) {
            right   = newBottomRight.x
            bottom  = newBottomRight.y
        }
    }

    public var centerX : Int {
        return topLeft.x + size.width / 2
    }

    public var centerY : Int {
        return topLeft.y + size.height / 2
    }

    public var center : Point {
        Point(x: centerX, y: centerY)
    }

    public init() {
        self.topLeft = Point()
        self.size = Size()
    }

    public init(size:Size) {
        self.topLeft = Point()
        self.size = size
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

    public func local(to origin:Rect) -> Rect {
        var localized = self
        localized.topLeft -= origin.topLeft
        return localized
    }

    public func containment(target:Point) -> ContainmentSet {
        var containmentSet = ContainmentSet()

        // Horizontal
        switch target.x {
            case let x where x < left:
                containmentSet.formUnion([.beyondLeft, .beyondHorizontally])
            case let x where x >= left && x < right:
                containmentSet.formUnion([.containedHorizontally])
            case let x where x >= right:
                containmentSet.formUnion([.beyondRight, .beyondHorizontally])
            default:
                fatalError("Failed to determine horizontal containment for point \(target) with rect \(self)")
        }

        // Vertical
        switch target.y {
        case let y where y < top:
            containmentSet.formUnion([.beyondTop, .beyondVertically])
        case let y where y >= top && y < bottom:
            containmentSet.formUnion([.containedVertically])
        case let y where y >= bottom:
            containmentSet.formUnion([.beyondBottom, .beyondVertically])
        default:
            fatalError("Failed to determine vertical containment for point \(target) with rect \(self)")
        }

        // Handle special cases
        switch containmentSet {
        case let set where set.isSuperset(of:[.beyondHorizontally, .beyondVertically]):
            containmentSet.formUnion([.beyondFully])
        case let set where set.isSuperset(of:[.containedHorizontally, .containedVertically]):
            containmentSet.formUnion([.containedFully])
        default:
            break;
        }

        // Handle contact
        if containmentSet.intersection([.beyondHorizontally, .beyondVertically]).isEmpty {
            containmentSet.formUnion([.contact])
        }

        return containmentSet
    }


    public func containment(target:Rect) -> ContainmentSet {
        var containmentSet = ContainmentSet()

        // Horizontal
        switch (target.left, target.right) {
        case let (_, targetRight)  where targetRight < left:
            containmentSet.formUnion([.beyondLeft, .beyondHorizontally])
        case let (targetLeft, targetRight) where targetRight >= left && targetRight < right && targetLeft < left:
            containmentSet.formUnion([.overlapsLeft])
        case let (targetLeft, targetRight) where targetRight >= right && targetLeft < left:
            containmentSet.formUnion([.overlapsLeft, .overlapsRight, .overlapsHorizontally])
        case let (targetLeft, targetRight) where targetRight >= right && targetLeft >= left && targetLeft < right:
            containmentSet.formUnion([.overlapsRight])
        case let (targetLeft, targetRight) where targetRight < right && targetRight >= left && targetLeft >= left && targetLeft < right:
            containmentSet.formUnion([.containedHorizontally])
        case let (targetLeft, _)  where targetLeft >= right:
                containmentSet.formUnion([.beyondRight, .beyondHorizontally])
            default:
                fatalError("Failed to determine horizontal containment for point \(target) with rect \(self)")
        }

        // Vertical
        switch (target.top, target.bottom) {
        case let (_, targetBottom) where targetBottom < top:
            containmentSet.formUnion([.beyondTop, .beyondVertically])
        case let (targetTop, targetBottom) where targetBottom >= top && targetBottom < bottom && targetTop < top:
            containmentSet.formUnion([.overlapsTop])
        case let (targetTop, targetBottom) where targetBottom >= bottom && targetTop < top:
            containmentSet.formUnion([.overlapsTop, .overlapsBottom, .overlapsVertically])
        case let (targetTop, targetBottom) where targetBottom >= bottom && targetTop >= top && targetTop < bottom:
            containmentSet.formUnion([.overlapsBottom])
        case let (targetTop, targetBottom) where targetBottom < bottom && targetBottom >= top && targetTop >= top && targetTop < bottom:
            containmentSet.formUnion([.containedVertically])
        case let (targetTop, _) where targetTop >= bottom:
            containmentSet.formUnion([.beyondBottom, .beyondVertically])
        default:
            fatalError("Failed to determine vertical containment for point \(target) with rect \(self)")
        }

        // Handle special cases
        switch containmentSet {
        case let set where set.isSuperset(of:[.beyondHorizontally, .beyondVertically]):
            containmentSet.formUnion([.beyondFully])
        case let set where set.isSuperset(of:[.containedHorizontally, .containedVertically]):
            containmentSet.formUnion([.containedFully])
        case let set where set.isSuperset(of:[.overlapsHorizontally, .overlapsVertically]):
            containmentSet.formUnion([.overlapsFully])
        default:
            break;
        }

        // Handle contact
        if containmentSet.intersection([.beyondHorizontally, .beyondVertically]).isEmpty {
            containmentSet.formUnion([.contact])
        }

        return containmentSet
    }

    /// Union of this `Rect` with the specified target `Rect` 
    /// - Returns: A new `Rect` exactly large enough to contain
    ///            both rectangles
    public func unioned(with other:Rect) -> Rect {
        let leftMost  = min(self.left, other.left)
        let rightMost = max(self.right, other.right)

        let topMost    = min(self.top, other.top)
        let bottomMost = max(self.bottom, other.bottom)

        let unionTopLeft = Point(x:leftMost, y:topMost)
        let unionSize    = Size(width:rightMost - leftMost,
                                height:bottomMost - topMost)

        let unionRect = Rect(topLeft:unionTopLeft, size:unionSize)
        return unionRect
    }

    /// Returns a new rect expanded by the amount specified while
    /// preserving the center point (negative numbers reduce the dimensions)
    /// - Parameters:
    ///   - change: The amount by which to increase each dimension
    /// - Returns: The inflated rect
    public func inflated(by change:Int) -> Rect {
        return inflated(by:Size(width:change, height:change))
    }
    
    /// Expands the rect by the amount specified while preserving the center point
    /// (negative numbers reduce the dimensions)
    /// - Parameters:
    ///   - change: The amount by which to increase all dimensions
    public mutating func inflate(by change:Int) {
        let inflatedRect = inflated(by:change)
        topLeft = inflatedRect.topLeft
        size    = inflatedRect.size
    }

    /// Returns a new rect expanded by the amount specified while
    /// preserving the center point (negative numbers reduce the dimensions)
    /// - Parameters:
    ///   - change: The amount by which to increase each dimension
    /// - Returns: The inflated rect
    public func inflated(by change:Size) -> Rect {
        let rect = Rect(topLeft:Point(x:topLeft.x - change.width,
                                      y:topLeft.y - change.height),
                        size:Size(width:size.width + change.width * 2,
                                  height:size.height + change.height * 2))
        return rect
    }

    /// Expands the rect by the amount specified while preserving the center point
    /// (negative numbers reduce the dimensions)
    /// - Parameters:
    ///   - change: The amount by which to increase each dimension
    public mutating func inflate(by change:Size) {
        let inflatedRect = inflated(by:change)
        topLeft = inflatedRect.topLeft
        size    = inflatedRect.size
    }
    
    /// Equivalence operator for two `Rect`s
    static public func == (lhs:Rect, rhs:Rect) -> Bool {
        return lhs.topLeft == rhs.topLeft && lhs.size == rhs.size
    }
    
    
}
