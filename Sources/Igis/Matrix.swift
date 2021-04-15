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

// This class represents a 3 x 3 matrix of Doubles and provides supporting
// functionality to handle 2D transforms
public class Matrix : CustomStringConvertible {
    private static let identityValues = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]

    public typealias Vector = [Double] // Must contain exactly 3 elements
    public let values : [[Double]] // Must be 3x3 matrix

    // Creates a matrix from a transform (used for the HTML Canvas)
    public init(transform:Transform) {
        let values = transform.values
        precondition(values.count == 6, "transform must have exactly six elements")
        let row1 = [values[0], values[1],       0.0]
        let row2 = [values[2], values[3],       0.0]
        let row3 = [values[4], values[5],       1.0]
        self.values = [row1, row2, row3]
    }

    // Creates a matrix from a 3x3 array
    public init(values:[[Double]]) {
        precondition(values.count == 3, "values must be a 3x3 array")
        for rowIndex in 0..<3 {
            precondition(values[rowIndex].count == 3, "values must be a 3x3 array")
        }
        self.values = values
    }

    // Returns the specified row
    public func row(_ rowIndex:Int) -> Vector {
        precondition((0..<3).contains(rowIndex), "Expected index in range 0..<3")

        var vector = Vector()
        for columnIndex in 0..<3 {
            vector.append(values[rowIndex][columnIndex])
        }

        return vector
    }

    // Returns the specifed column
    public func column(_ columnIndex:Int) -> Vector {
        precondition((0..<3).contains(columnIndex), "Expected index in range 0..<3")

        var vector = Vector()
        for rowIndex in 0..<3 {
            vector.append(values[rowIndex][columnIndex])
        }
        
        return vector
    }

    // Returns the dot product of two vectors
    public func dotProduct(left:Vector, right:Vector) -> Double {
        precondition(left.count == 3, "Expected left.count to be 3")
        precondition(right.count == 3, "Expected right.count to be 3")

        var sum = 0.0
        for index in 0..<3 {
            sum += left[index] * right[index]
        }
        return sum
    }
    
    public var description : String {
        // Convert to strings and pad all to uniform length
        let allValues : [Double] = Array<Double>(values.joined())
        let allStrings = allValues.map {"\($0)"}
        let longestCount = allStrings.reduce(0) {(result:Int, s:String) in max(s.count, result)}
        let paddingCount = longestCount + 2
        let paddedStrings = allStrings.map {$0.padding(toLength:paddingCount, withPad:" ", startingAt:0)}

        // Form the string
        var s = ""
        for row in 0 ..< 3 {
            s += "[ "
            for column in 0 ..< 3 {
                s += paddedStrings[row * 3 + column]
            }
            s += "]\n"
        }

        return s
    }

    // Mutliplies this matrix by another and returns the resultant matrix
    public func multiply(byMatrix:Matrix) -> Matrix {
        var values = Array(repeating:Array(repeating:0.0, count:3), count:3)
        for rowIndex in 0..<3 {
            for columnIndex in 0..<3 {
                let rowVector = byMatrix.row(rowIndex)
                let columnVector = self.column(columnIndex)
                let result = dotProduct(left:rowVector, right:columnVector)
                values[rowIndex][columnIndex] = result
            }
        }

        return Matrix(values:values)
    }

    // Applies the matrix to the provided DoublePoint and returns the result
    public func apply(toDoublePoint:DoublePoint) -> DoublePoint {
        let source : Vector = [toDoublePoint.x, toDoublePoint.y, 1]
        var target : Vector = Array(repeating:0.0, count:3)
        for index in 0 ..< 3 {
            let columnVector = self.column(index)
            target[index] = dotProduct(left:source, right:columnVector)
        }
        return DoublePoint(x:target[0], y:target[1])
    }

    // Applies the matrix to the provided Point and returns the result
    public func apply(toPoint:Point) -> Point {
        let applied = apply(toDoublePoint:DoublePoint(toPoint))
        return Point(applied)
    }

    // Applies the matrix to the provided array of DoublePoint and returns the result
    public func apply(toDoublePoints:[DoublePoint]) -> [DoublePoint] {
        return toDoublePoints.map {apply(toDoublePoint:$0)}
    }

    // Applies the matrix to the provided array of Point and returns the result
    public func apply(toPoints:[Point]) -> [Point] {
        return toPoints.map {apply(toPoint:$0)}
    }

    // Mutliply a series of matrices and returns the resultant matrix
    // If no matrices are provided, the identity matrix will be returned
    public static func multiply(matrices:[Matrix]) -> Matrix {
        var result = Matrix(values:Self.identityValues)
        for matrix in matrices {
            result = result.multiply(byMatrix:matrix)
        }
        return result
    }
}
