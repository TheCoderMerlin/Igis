/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2020 CoderMerlin.com
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

/// `Layout` provides the ability to layout a series of `Rect`s using
/// specified rules.  The order of each `Rect` is always preserved.
public class Layout  {

    public enum ChildAttribute {
        /// Calculcates the maximum width of all `Rect`s
        case maxWidth
        /// Calculcates the maximum height of all `Rect`s
        case maxHeight

        /// Calculates the full width of all `Rect`s
        /// (width from left-most to right-most)
        case fullWidth
        /// Calculates the full height of all `Rect`s
        /// (height from top-most to bottom-most)
        case fullHeight
        
        
        /// Calculates the top-most top of all `Rect`s
        case topMost
        /// Calculates the bottom-most bottom of all `Rect`s
        case bottomMost
        /// Calculates the left-most left of all `Rect`s
        case leftMost
        /// Calculates the right-most right of all `Rect`s
        case rightMost
    }
    
    public enum ChildRule {
        /// Sets the width of all `Rect`s as specified
        case alignWidths(width:Int)
        /// Sets the height of all `Rect`s as specified
        case alignHeights(height:Int)

        /// Sets the top of all `Rect`s as specified
        case alignTops(top:Int)
        /// Sets the bottom of all `Rect`s as specified
        case alignBottoms(bottom:Int)
        /// Sets the left of all `Rect`s as specified
        case alignLefts(left:Int)
        /// Sets the right of all `Rect`s as specified
        case alignRights(right:Int)

        /// Distributes the `Rect`s horizontally beginning at the
        /// specified *left* placing *padding* between each `Rect`
        case distributeHorizontally(left:Int, padding:Int)
        /// Distrbutes the `Rect`s vertically beginning at the
        /// specified *top* placing *padding* between each `Rect`
        case distributeVertically(top:Int, padding:Int)
    }

    /// Applies the specified change and returns a new altered `Rect` reflecting that change
    private static func newAltered(_ source:Rect, by change:(_ rect:inout Rect)->Void) -> Rect {
        var newRect = source
        change(&newRect)
        return newRect
    }

    /// Analyzes the childRects and calculates the specified property of the collection
    public static func property(attribute:ChildAttribute, childRects:[Rect]) -> Int {
        switch attribute {
        case .maxWidth:
            return childRects.reduce(Int.min) {max($0, $1.size.width)}
        case .maxHeight:
            return childRects.reduce(Int.min) {max($0, $1.size.height)}

        case .fullWidth:
            let leftMost  = property(attribute:.leftMost, childRects:childRects)
            let rightMost = property(attribute:.rightMost, childRects:childRects)
            return rightMost - leftMost
        case .fullHeight:
            let topMost  = property(attribute:.topMost, childRects:childRects)
            let bottomMost = property(attribute:.bottomMost, childRects:childRects)
            return bottomMost - topMost

        case .topMost:
            return childRects.reduce(Int.max) {min($0, $1.top)}
        case .bottomMost:
            return childRects.reduce(Int.min) {max($0, $1.bottom)}
        case .leftMost:
            return childRects.reduce(Int.max) {min($0, $1.left)}
        case .rightMost:
            return childRects.reduce(Int.min) {max($0, $1.right)}
        }
    }

    /// Applies the specified rule to the collection of `Rect`s and returns
    /// a new collection, maintaining the original order
    public static func apply(rule:ChildRule, childRects:[Rect]) -> [Rect] {
        let newChildRects : [Rect]
        switch rule {
        case .alignWidths(let width):
            newChildRects = childRects.map {newAltered($0, by: {(r) in r.width = width})}
        case .alignHeights(let height):
            newChildRects = childRects.map {newAltered($0, by: {(r) in r.height = height})}
            
        case .alignTops(let top):
            newChildRects = childRects.map {newAltered($0, by: {(r) in r.top = top})}
        case .alignBottoms(let bottom):
            newChildRects = childRects.map {newAltered($0, by: {(r) in r.bottom = bottom})}
        case .alignLefts(let left):
            newChildRects = childRects.map {newAltered($0, by: {(r) in r.left = left})}
        case .alignRights(let right):
            newChildRects = childRects.map {newAltered($0, by: {(r) in r.right = right})}

        case .distributeHorizontally(let left, let padding):
            var currentLeft = left
            var calculatingRects = [Rect]()
            for childRect in childRects {
                calculatingRects.append(newAltered(childRect, by: {(r) in r.topLeft = Point(x:currentLeft, y:r.top)}))
                currentLeft += childRect.size.width + padding
            }
            newChildRects = calculatingRects
        case .distributeVertically(let top, let padding):
            var currentTop = top
            var calculatingRects = [Rect]()
            for childRect in childRects {
                calculatingRects.append(newAltered(childRect, by: {(r) in r.topLeft = Point(x:r.left, y:currentTop)}))
                currentTop += childRect.size.height + padding
            }
            newChildRects = calculatingRects
        }
        
        return newChildRects
    }

    
    
}
