# IGIS
IGIS provides a Swift object library running as a server on Linux for remote graphics via a browser client.

[Very Preliminary API Documentation](https://thecodermerlin.github.io/Igis/)

## Usage

### Library
In order to use the library, use the project IgisShellD as a starting point.


### Point
```swift
// Point Definition
public var x : Int
public var y : Int

public init()
public init(x:Int, y:Int)
public init(doublePoint:DoublePoint)

public func distanceSquared(target:Point) -> Int
public func distance(target:Point) -> Double

static public func Points(doublePoints:[DoublePoint]) -> [Point]
```

### DoublePoint
```swift
// DoublePoint Definition
public init()
public init(x:Double, y:Double)
public init(point:Point)

public func distanceSquared(target:DoublePoint)
public func distance(target:DoublePoint)

public func DoiublePoints(points:[Point]) -> [DoublePoint]
```

### Size
```swift
// Size Definition
public var width : Int
public height : Int 

public init() 
public init(width:Int, height:Int)

public mutating func enlarge(change:Int)

public var center : Point // Calculated
```

### Containment
```swift
// Provides a description of a rectangle relative to a target Point or Rect    
public enum Containment {
    // Special cases combining horizontal and vertical containment
    case containedFully           // Included in set when both containedHorizontally AND containedVertically (Points,Rects)
    case overlapsFully            // Included in set when both overlapsHorizontally AND overlapsVertically   (Rects only)
    case beyondFully              // Included in set when both beyondHorizontally AND beyondVertically       (Points,Rects)
	case contact                  // Included in set when target is in contact with rectangle                (Points, Rects)

    // Horizontal cases
    case beyondLeft               // Indicates target's right side is beyond (to left of) object             (Points,Rects)
    case overlapsLeft             // Indicates target's left is beyond left but target's right is            (Rects only)
                                  //     within or beyond object (toward right)
    case beyondHorizontally       // Included in set when either beyondLeft OR beyondRight                   (Points,Rects)
    case containedHorizontally    // Target is contained within left and right of object                     (Points,Rects)
    case overlapsHorizontally     // Included in set when both overlapsLeft AND overlapsRight                (Rects only)
    case overlapsRight            // Indicates target's right is beyond right but target's left is           (Rects only)
                                  //     within or beyond object (toward left)
    case beyondRight              // Indicates target's left side is beyond (to right of) object             (Points,Rects)

    // Vertical cases
    case beyondTop                // Indicates target's bottom side is beyond (on top of) object             (Points,Rects)
    case overlapsTop              // Indicates target's top is beyond top but target's bottom is             (Rects only)
                                  //     within or beyond object (toward bottom)
    case beyondVertically         // Included in set when either beyondTop OR beyondBottom                   (Points,Rects)
    case containedVertically      // Target is contained within top and bottom of object                     (Points,Rects)
    case overlapsVertically       // Included in set when both overlapsTop AND overlapsBottom                (Points,Rects)
    case overlapsBottom           // Indicates target's bottom is beyond bottom but target's top is          (Rects only)
                                  //     within or beyond object (toward top)
    case beyondBottom             // Indicates target's top side is beyond (below) object                    (Points,Rects)
}
```

### Rect
```swift
// Rect Definition
public var topLeft : Point
public var size : Size
public var center : Point // Calculated

public init() 
public init(topLeft:Point, size:Size)
public init(bottomLeft:Point, size:Size)
public init(topRight:Point, size:Size)
public init(bottomRight:Point, size:Size)

public var left : Int   // Calculated
public var top : Int    // Calculated
public var right : Int  // Calculated
public var bottom : Int // calculated

public func local(to origin:Rect) -> Rect 

public func containment(target:Point) -> ContainmentSet
public func containment(target:Rect) -> ContainmentSet

public func unioned(other:Rect) -> Rect

public func inflated(change:Int) -> Rect
public mutating func inflate(change:Int)
public func inflated(change:Size) -> Rect
public mutating func inflate(change:Size)

```

### Matrix
```swift
// Matrix Definition
public typealias Vector = [Double]

public init(transform:Transform)
public init(values:[[Double]])

public func row(_ rowIndex:Int) -> Vector
public func column(_ columnIndex:Int) -> Vector
public func dotProduct(left:Vector, right:Vector) -> Double

public var description : String

public func multiply(byMatrix:Matrix) -> Matrix
public func apply(toDoublePoint:DoublePoint) -> DoublePoint
public func apply(toPoint:Point) -> Point
public func apply(toDoublePoints:[DoublePoint]) -> [DoublePoint]
public func apply(toPoints:[Point]) -> [Point]

static func multiply(matrices:[Matrix]) -> Matrix
```

### Color
```swift
// Color Definition
public init (red:UInt8, green:UInt8, blue:UInt8)
public init(_ name:Name)

public var red : UInt8 // Calculated
public var green : UInt8 // Calculated
public var blue : UInt8 // Calculated
```
Note:  Color names are from [w3 org](https://www.w3.org/TR/css-color-3/#svg-color).

### Gradients
Gradients must be setup before being rendered.
Gradients are created by specifying a series of colors across a range of positions, from 0.0 to 1.0.
There are two types of gradients, linear and radial.  Both may be used for either StrokeStyle or FillStyle.
```swift
// ColorStop Definition
public init(position:Double, color:Color)

// Gradient Definition
public enum Mode {
    case linear(start:Point, end:Point)
    case radial(center1:Point, radius1:Double, center2:Point, radius2:Double)
}
public init(mode:Mode)
func addColorStop(_ colorStop:ColorStop)
```

### StrokeStyle
```swift
// StrokeStyle Definition
public init(color:Color)
public init(gradient:Gradient)
```

### FillStyle
```swift
// FillStyle Definition
 public init(color:Color)
 public init(gradient:Gradient)
 public init(pattern:Pattern)
 ```

### Painting 
The painting of all objects occurs on a "canvas".  The coordinate system of the canvas begins at (0,0) in the top-left corner.  X increases toward right, and Y increases toward the bottom.  Throughout this document, unless otherwise noted, all units are pixels.

**IMPORTANT:** Merely creating an object will not affect the display on the Canvas.
In order for an object to be visible it must be painted on the canvas.

```swift
canvas.render(helloWorld)
```

Most objects can be created at anytime, however they may only be painted in an event which provides a Canvas as a parameter.  The [IgisShell project](https://github.com/TangoGolfDigital/IgisShell) provides a useful shell to get started.  In order to start Igis, a class implementing the PainterProtocol is required:

```swift
class Painter : PainterBase {
    required init() {
    }

    override func setup(canvas:Canvas) {
    }

    override func calculate(canvasId:Int, canvasSize:Size?) {
        // Calculate position and movement of objects here
        // The canvasId may be used to distinguish between different clients
    }

    override func render(canvas:Canvas) {
        // Render objects here
    }

    override func onClick(location:Point) {
    }
}
```

In order to start Igis, the type of class is passed as an argument to Igis's run function:
```swift
print("Starting...")
do {
    let igis = Igis()
    try igis.run(painterType:Painter.self)
} catch (let error) {
    print("Error: \(error)")
}
```

As a shortcut, if only a few methods are required to be overridden, the PainterBase class 
is available as a starting point.

### Text
```swift
// Text Definition
public init(location:Point, text:String, fillMode:FillMode = .fill)

// Optional:
font = "10pt Arial"
alignment = .left | .center | .right
baseline = .top | .hanging | .middle | .alphabetic | .ideographic | .bottom
```

```swift
// Create a text object to be painted at location (x:100, y:100) using the current font 
// and current fill color.
// By default, the text will be filled.
let helloWorld = Text(location:Point(x:100, y:100), text:"Hello, World!") 
```

```swift
// Create a text object with a specific font using the current fill color.
let helloWorld = Text(location:Point(x:100, y:100), text:"Hello, World!")
helloWorld.font = "50pt Arial bold"
```

```swift
// Stroke the text using the current stroke color rather than fill.
let helloWorld = Text(location:Point(x:100, y:100), text:"Hello, World!", fillMode:.stroke) 
helloWorld.font = "50pt Arial bold"
```
### TextMetric
TextMetric provides metrics regarding text and enables the determination of the bounding rect of arbitrary text, whether or not it is actually rendered.
```swift
// TextMetric definition
// Create a new TextMetric object from the specified text 
public init(text:String)
// Optional:
font = "10pt Arial"
alignment = .left | .center | .right
baseline = .top | .hanging | .middle | .alphabetic | .ideographic | .bottom

// Create a new TextMetric object from the specified Text object
// This has the benefit of also setting the font, alignment, and baseline, if specified in the text object
public init(fromText:Text)
```

```swift
// TextMetric metrics are updated soon after they are rendered
// There's no point in rendering a TextMetric if it's already been rendered and hasn't changed
if textMetric.currentMetrics == nil {  
    canvas.render(textMetric) 
}
```

```swift
// TextMetric metrics can most easily be used as follows:
if let metrics = textMetric.mostRecentMetrics {   
    let rect = metrics.actualBoundingBox(location:text.location)
    let rect = metrics.fontBoundingBox(location:text.location)  
}
```

### Rectangle
```swift
// Rectangle Definition
public init(rect:Rect, fillMode:FillMode = .fill)
```

```swift
// Create a rectangle to be painted at location (x:100, y:100) of width 200 and height 100
// using the current fill color.
let box = Rectangle(rect:Rect(topLeft:Point(x:100, y:100), size:Size(width:200, height:100)))
```

```swift
// Create a rectangle to be stroked and filled using the current stroke color and current fill color.
let box = Rectangle(rect:Rect(topLeft:Point(x:100, y:100), size:Size(width:200, height:100)), fillMode:.fillAndStroke)
```

### Ellipse
```swift
// Ellipse Definition
public init(center:Point, radiusX:Int, radiusY:Int, 
rotation:Double=0.0, startAngle:Double=0.0, endAngle:Double=2.0*Double.pi,                                  
antiClockwise:Bool=false, fillMode:FillMode = .stroke)
```

### Lines
```swift
// Lines Definition
public init(from:Point, to:Point)

public func moveTo(_ point:Point) // Moves to the specified point without drawing

public func lineTo(_ point:Point) // Draws a line to the specified point

```

### Transforms
Transforms may be applied using the Transform object

```swift
// Translation
let transform = Transform(translate:DoublePoint(x:10, y:10))

// Rotation
let radians = 1.0 * Double.pi / 180.0 
let transform = Transform(rotateRadians:radians)

// Scale
let transform = Transform(scale:DoublePoint(x:1.1, y:1.1))    

// Shear
let transform = Transform(shear:DoublePoint(x:0.0, y:0.2))

// Return to identity transform
let transform = Transform() // or
let transform = Transform(mode: .toIdentity)

// Create a transform from a matrix
le transform = Transform(matrix:Matrix, mode:Mode)

// Mutliply transforms
public static func multiply(transforms:[Transform], mode:Mode = .fromCurrent) -> Matrix
```

### Alpha
Alpha may be applied using the Alpha object

```swift
let alpha = Alpha(alphaValue:0.3)
```

### State
State may be saved and subsequently restored on a stack

```swift
let save = State(mode:.save)
...
let restore = State(mode:.restore)
```

### Paths
Paths may be used to contruct arbitrary shapes

Paths support several operations:
* moveTo
* lineTo
* rect
* quadraticCurveTo
* bezierCurveTo
* arc
* arcTo

```swift
let path = Path(fillMode:.fillAndStroke)
path.moveTo(Point(x:900, y:100))
path.lineTo(Point(x:1000, y:100))
path.quadraticCurveTo(controlPoint:Point(x:1000, y:200), endPoint:Point(x:900, y:200))
path.lineTo(Point(x:1000, y:200))
path.bezierCurveTo(controlPoint1:Point(x:1100, y:250), controlPoint2:Point(x:950, y:350), endPoint:Point(x:900, y:300))
path.arc(center:Point(x:950, y:350), radius:50, startAngle:Double.pi, endAngle:2*Double.pi, antiClockwise:true)
path.arcTo(controlPoint1:Point(x:1200, y:300), controlPoint2:Point(x:1200, y:400), radius:50)
path.lineTo(Point(x:850, y:500))
path.linesTo(points)
path.close()

let pathFromPoints = Path(points:[Point], fillMode:FillMode = .stroke)
```

### Clipping
Drawing may be clipped to a path by rendering a clipPath.

```swift
let clip = clipPath(path:Path(), windingRule:.evenOdd) // or
let clip = clipPath(path:Path(), windingRule:.nonZero)
```

### Turtle Graphics
In addition to the above objects, Igis supports traditional turtle graphics.  For turtle graphics, the coordinate system is different.  In this coordinate system, the center of the canvas is labeled as the origin (0,0), termed "home".  When the turtle is in the home position, it is oriented up.  Rotating to the right rotates the turtle clockwise from north the specified number of degreess, rotating left rotates the turtle counter-clockwise the specified number of degrees.  The turtle can also move forwards or backwards a specified number of steps in the direction in which it is currently pointed.  

Note:  It's OK to mix objects and turtle graphics.

```swift
// Turtle Definition
public init(canvasSize:Size)

public func forward(steps:Int) // Move forward the specified number of steps
public func backward(steps:Int) // Move backward the specified number of steps

public func left(degrees:Double) // Turn left (counter-clockwise) the specified number of degrees
public func right(degrees:Double) // Turn right (clockwise) the specified number of degrees

public func penUp() // Lift the pen.  Subsequent movement will not be visible.
public func penDown() // Drop the pen.  Subsequent movement will be visible.

public func penColor(color:Color) // Set the color of the pen
public func penWidth(width:Int) // Set the width of the pen

public func push() // Push the current position, angle, and pen attributes onto the stack
public func pop() // Pop the previously pushed position, angle, and pen attributes
public func home() // Return to the home position
```

### Audio
Audio may be rendered in a manner similar to images.

```swift
// Audio Definition
public init(sourceURL:URL, shouldLoop:Bool = false)
```

To play audio, render it in the same manner as images:
```swift
required init() {
    ...
    background = Audio(sourceURL:backgroundURL, shouldLoop:true)
}

override func render(canvas:Canvas) {
    ...
    if !isBackgroundPlaying && background.isReady {
        canvas.render(background) 
        isBackgroundPlaying = true 
    }
}
```

### Keyboard Input
Keyboard input is available from the painter methods:
```swift
    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)
    func onKeyUp(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)
```

### Mouse Input
Mouse input is availabe from the painter methods:
```swift
    func onClick(location:Point)
    func onMouseDown(location:Point)
    func onMouseUp(location:Point)
    func onWindowMouseUp(location:Point)
    func onMouseMove(location:Point)
```

### Cursor Style
Cursor style may be set by rendering a CursorStyle object with the desired style.

Set the new style in render()
```swift
override func render(canvas:Canvas) {
    ...
    let cursorStyle = CursorStyle(style:nextStyle)
    canvas.render(cursorStyle)
    ...
}
```

Available styles:
```swift
    public enum Style : String {
        // Defaults
	    case initial
        case auto
        case defaultCursor

 	    // None
	    case none

        // Waiting
        case progress
        case wait

	    // Pointer types
	    case pointer
	    case crosshair
	    case help
	    case contextMenu
	    case alias

        // Text and cells
	    case text
	    case textVertical
	    case cell

        // Movement and dragging
	    case notAllowed
	    case noDrop

        case allScroll

        case move
	    case copy

        case resizeNorth
	    case resizeNorthEast
	    case resizeEast
	    case resizeSouthEast
	    case resizeSouth
	    case resizeSouthWest
	    case resizeWest
	    case resizeNorthWest

        case resizeRow
	    case resizeColumn

        // Zooming
	    case zoomIn
	    case zoomOut
   }
```
