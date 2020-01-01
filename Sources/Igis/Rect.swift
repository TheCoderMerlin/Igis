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
        get {
            return topLeft.x
        }
        set (newLeft) {
            let delta = newLeft - topLeft.x
            topLeft.moveXBy(offset:delta)
            size.enlargeWidthBy(change:-delta)
        }
    }

    public var top : Int {
        get {
            return topLeft.y
        }
        set (newTop) {
            let delta = newTop - topLeft.y
            topLeft.moveYBy(offset:delta)
            size.enlargeHeightBy(change:-delta)
        }
    }

    public var right : Int {
        get {
            return topLeft.x + size.width
        }
        set (newRight) {
            let delta = newRight - (topLeft.x + size.width)
            size.enlargeWidthBy(change:delta)
        }
    }

    public var bottom : Int {
        get {
            return topLeft.y + size.height
        }
        set (newBottom) {
            let delta = newBottom - (topLeft.y + size.height)
            size.enlargeHeightBy(change:delta)
        }
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

    public init(source:Rect) {
        self.topLeft = source.topLeft
        self.size = source.size
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

        return containmentSet
    }

    /*
    public func containment(target:Rect) -> ContainmentSet {
        var containmentSet = ContainmentSet()

        // Horizontal
        switch (target.left, target.right) {
        case let (targetLeft, targetRight)  where targetRight < left:
            containmentSet.formUnion([.beyondLeft, .beyondHorizontally])
        case let (targetLeft, targetRight) where targetRight >= left && targetLeft < left:
            containmentSet.formUnion([.overlapsLeft, .overlapsHorizontally])
        case let (targetLeft, targetRight) where targetRight >= right && targetLeft < left:
            containmentSet.formUnion([.overlapsLeft, .overlapsRight, .overlapsHorizontally])
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

        return containmentSet
    }
    
     */
    
}
