/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018, 2019 Tango Golf Digital, LLC
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

public class Transform : CanvasObject {

    private static let identityTransform : Array<Double> = [1, 0, 0, 1, 0, 0]
    
    public enum Mode {
        case toIdentity    // Transform TO the identity 
        case fromIdentity  // Apply a new transform, starting from the identity
        case fromCurrent   // Apply a new transform, starting from the current transform
    }

    private let mode : Mode
    internal let transform : Array<Double>
    
    public init(mode:Mode = .toIdentity) {
        self.mode = mode
        transform = Transform.identityTransform
    }

    public init(scale:DoublePoint, mode:Mode = .fromCurrent) {
        self.mode = mode
        transform = [scale.x, 0, 0, scale.y, 0, 0]
    }

    public init(rotateRadians:Double, mode:Mode = .fromCurrent) {
        self.mode = mode
        let c = cos(rotateRadians)
        let s = sin(rotateRadians)
        transform = [c, s, -s, c, 0, 0]
    }

    public init(translate:DoublePoint, mode:Mode = .fromCurrent) {
        self.mode = mode
        transform = [1, 0, 0, 1, translate.x, translate.y]
    }

    public init(shear:DoublePoint, mode:Mode = .fromCurrent) {
        self.mode = mode
        transform = [1, shear.y, shear.x, 1, 0, 0]
    }

    internal override func canvasCommand() -> String {
        guard transform.count == 6 else {
            fatalError("Transforms must contain exactly six elements")
        }
        
        var commands = (mode == .fromCurrent) ? "transform" : "setTransform"
        commands += "|"
        
        let transformAsString = transform.map {"\($0)"}.joined(separator:"|")
        commands +=  transformAsString 
        return commands
    }
    
}
