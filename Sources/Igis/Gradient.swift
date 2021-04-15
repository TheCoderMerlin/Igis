/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018 CoderMerlin.com
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


/// A `Gradient` is used to create a `FillStyle` for filling various objects.
///
/// `Gradient`s have two flavors:
/// 1. Linear
/// 2. Radial
///
/// ### Usage:
/// There are several steps required to use a gradient:
/// 1. Create the Gradient object
/// 2. Add two or more ColorStops
/// 3. Setup the Gradient object
/// 4. Use the Gradient to initialize a StrokeStyle or FillStyle
/// 5. Because the Gradient is a CanvasIdentifiedObject, be sure it `isReady`
///    prior to rendering
/// 6. Render the associated FillStyle prior to the object(s) to be filled
///    with the gradient
///
/// ### Example:
///
/// ~~~
/// var gradient : Gradient
///
/// init() {
///     gradient = Gradient(mode:.linear(start:Point(x:0, y:60), end:Point(x:320, y:60)))
///     gradient.addColorStop(ColorStop(position:0.0, color:Color(.red)))
/// 	gradient.addColorStop(ColorStop(position:0.25, color:Color(.yellow)))
///     gradient.addColorStop(ColorStop(position:0.5, color:Color(.green)))
///     gradient.addColorStop(ColorStop(position:0.5, color:Color(.green)))
///     gradient.addColorStop(ColorStop(position:0.5, color:Color(.green)))
/// }
///
/// override func setup(canvas:Canvas) {
///     canvas.setup(gradient) 
/// }
///
/// override func render(canvas:Canvas) {
///     if gradient.isReady {
/// 	    let fillStyle = FillStyle(gradient:gradient)
/// 	    canvas.render(fillStyle, rectangle)
/// 	}
/// }
/// ~~~

public class Gradient : CanvasIdentifiedObject {

    /// The `Mode` is used to determine whether this is a `linear` or `radial` `Gradient`.
    ///
    /// NB: `Gradient` coordinates are global and are not relative to the rendered
    ///     object's coordinates.
    public enum Mode {
    	/// Creates a gradient along the line connecting the two given coordinates
        case linear(start:Point, end:Point)
	
	/// Creates a radial gradient using the size and coordnates of two circles
        case radial(center1:Point, radius1:Double, center2:Point, radius2:Double)
    }
    
    public let mode : Mode

    /// Maintains a list of colorStops for this Gradient.
    ///
    ///  NB: This cannot be changed after setup() has been invoked.
    public private(set) var colorStops : [ColorStop]

    /// Creates a new `Gradient`
    ///	- Parameters:
    ///	  - mode: Specifies the `Gradient` mode (linear or radial)
    public init(mode:Mode) {
        self.mode = mode
        self.colorStops = [ColorStop]()
    }

    /// Adds a `ColorStop` to the `Gradient`.
    /// - Parameters:
    ///  - colorStop: The `ColorStop` to be added
    public func addColorStop(_ colorStop:ColorStop) {
        colorStops.append(colorStop)
    }

    internal override func canvasCommand() -> String {
        print("ERROR: canvasCommand requested on gradient which may not be directly rendered. ID: \(id.uuidString).")
        return ""
    }

    internal override func setupCommand() -> String {
        var commands = ""
        switch mode {
        case .linear(let start, let end):
            commands += "createLinearGradient|\(id.uuidString)|\(start.x)|\(start.y)|\(end.x)|\(end.y)|\(colorStops.count)|"
        case .radial(let center1, let radius1, let center2, let radius2):
            commands += "createRadialGradient|\(id.uuidString)|\(center1.x)|\(center1.y)|\(radius1)|\(center2.x)|\(center2.y)|\(radius2)|\(colorStops.count)|"            
        }
        commands += colorStops.map {"\($0.position)|\($0.color.style)"}.joined(separator:"|")
        
        return commands
    }
}
