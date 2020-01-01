# IGIS

IGIS provides a Swift object library running as a server on Linux for remote graphics via a browser client.

## Usage

### Library
In order to use the library, include this resource as a dependency in Package.swift

```swift
// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IgisShell",
    dependencies: [
      .package(url: "https://github.com/TangoGolfDigital/Igis.git", from:"0.1.41"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "IgisShell",
            dependencies: ["Igis"]),
    ]
)
```

### Point
```swift
// Point Definition
public private (set) var x : Int
public private (set) var y : Int

public init(x:Int, y:Int)

public mutating func moveBy(offsetX:Int, offsetY:Int)
public mutating func moveBy(offset:Point)
public mutating func moveXBy(offset:Int)
public mutating func moveYBy(offset:Int)

public mutating func moveTo(x:Int, y:Int)
public mutating func moveTo(_ point:Point)
```

### DoublePoint
```swift
// DoublePoint Definition
public init(x:Double, y:Double)

public mutating func moveBy(offsetX:Double, offsetY:Double)

public mutating func moveTo(x:Double, y:Double)
```

### Size
```swift
// Size Definition
public private (set) var width : Int
public private (set) var height : Int 

public init(width:Int, height:Int)

public mutating func enlargeBy(changeWidth:Int, changeHeight:Int)
public mutating func enlargeWidthBy(change:Int)
public mutating func enlargeHeightBy(change:Int)

public mutating func changeTo(width:Int, height:Int)
```

### Containment
```swift


```

### Rect
```swift
// Rect Definition
public var topLeft : Point
public var size : Size 

public init(topLeft:Point, size:Size)
public init(bottomLeft:Point, size:Size)
public init(topRight:Point, size:Size)
public init(bottomRight:Point, size:Size)
public init(source:Rect)

public var left : Int
public var top : Int
public var right : Int
public var bottom : Int

public func containment(target:Point) -> ContainmentSet


```

### Color
```swift
// Color Definition
public init (red:UInt8, green:UInt8, blue:UInt8)

public init(_ name:Name)
```
Note:  Color names are from [w3 org](https://www.w3.org/TR/css-color-3/#svg-color).  If a name is not available it has an available synonym.  For example "grey" can be found by using "gray", and "aqua" can be found by using "cyan".

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
path.close()       
```

### Clipping
Drawing may be clipped to a path by first rendering the path and then

```swift
let clip = Clip(windingRule:.evenOdd) // or
let clip = Clip(windingRule:.nonZero)
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
