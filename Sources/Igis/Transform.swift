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

public class Transform : CanvasObject, CustomStringConvertible {

    private static let identityValues : Array<Double> = [1, 0, 0, 1, 0, 0]
    
    public enum Mode {
        case toIdentity    // Transform TO the identity 
        case fromIdentity  // Apply a new transform, starting from the identity
        case fromCurrent   // Apply a new transform, starting from the current transform
    }

    public let mode : Mode
    public let values : Array<Double>

    // Create an identity transform
    public init(mode:Mode = .toIdentity) {
        self.mode = mode
        values = Self.identityValues
    }

    // Creates a scaling transform
    public init(scale:DoublePoint, mode:Mode = .fromCurrent) {
        self.mode = mode
        values = [scale.x, 0, 0, scale.y, 0, 0]
    }

    // Creates a rotation transform
    public init(rotateRadians:Double, mode:Mode = .fromCurrent) {
        self.mode = mode
        let c = cos(rotateRadians)
        let s = sin(rotateRadians)
        values = [c, s, -s, c, 0, 0]
    }

    // Creates a translation transform
    public init(translate:DoublePoint, mode:Mode = .fromCurrent) {
        self.mode = mode
        values = [1, 0, 0, 1, translate.x, translate.y]
    }

    // Creates a shearing transform
    public init(shear:DoublePoint, mode:Mode = .fromCurrent) {
        self.mode = mode
        values = [1, shear.y, shear.x, 1, 0, 0]
    }

    // Creates a transform from a matrix
    public init(matrix:Matrix, mode:Mode = .fromCurrent) {
        self.mode = mode
        let values = matrix.values
        self.values = [values[0][0], values[0][1], values[1][0], values[1][1], values[2][0], values[2][1]]
    }

    internal override func canvasCommand() -> String {
        guard values.count == 6 else {
            fatalError("Transforms must contain exactly six elements")
        }
        
        var commands = (mode == .fromCurrent) ? "transform" : "setTransform"
        commands += "|"
        
        let transformAsString = values.map {"\($0)"}.joined(separator:"|")
        commands +=  transformAsString
        
        return commands
    }

    public var description : String {
        // Convert to strings and pad all to uniform length
        let strings = values.map {"\($0)"}
        let longestCount = strings.reduce(0) {(result:Int, s:String) in max(s.count, result)}
        let paddingCount = longestCount + 2
        let paddedStrings = strings.map {$0.padding(toLength:paddingCount, withPad:" ", startingAt:0)}

        // Form the string
        var s = ""
        for row in 0 ..< 3 {
            s += "["
            for column in 0 ..< 2 {
                s += paddedStrings[row * 2 + column]
            }
            s += "]\n"
        }

        return s
    }

    // Multiplies a series of transforms and returns the resultant Matrix
    // If no transforms are provided, the identiy matrix will be returned
    public static func multiply(transforms:[Transform], mode:Mode = .fromCurrent) -> Matrix {
        let matrices = transforms.map {Matrix(transform:$0)}
        return Matrix.multiply(matrices:matrices)
    }
    
}
