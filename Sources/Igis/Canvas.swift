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
import NIO

public class Canvas {

    private static let minimumSecondsBeforePing = 15
    private static var nextCanvasId : Int = 0
    private let painter : PainterProtocol
    private var pendingCommandList = [String]()
    private var identifiedObjectDictionary = [UUID:CanvasIdentifiedObject]()
    private var mostRecentPingTime = Date()

    public let canvasId : Int
    public private(set) var canvasSize : Size? = nil
    public private(set) var windowSize : Size? = nil
    
    internal init(painter:PainterProtocol) {
        // Assign ID.  Potentially conflict if two threads enter simultaneously?
        self.canvasId = Canvas.nextCanvasId
        Canvas.nextCanvasId += 1
        
        self.painter = painter
    }

    // MARK: ********** API **********

    public func render(_ canvasObjects:[CanvasObject]) {
        for canvasObject in canvasObjects {
            let command = canvasObject.canvasCommand()
            pendingCommandList.append(command)
        }
    }

    public func render(_ canvasObjects:CanvasObject...) {
        render(canvasObjects)
    }

    public func setup(_ canvasIdentifiedObjects:[CanvasIdentifiedObject]) {
        for canvasIdentifiedObject in canvasIdentifiedObjects {
            identifiedObjectDictionary[canvasIdentifiedObject.id] = canvasIdentifiedObject
            
            let command = canvasIdentifiedObject.setupCommand()
            pendingCommandList.append(command)
            
            canvasIdentifiedObject.setState(.transmissionQueued)
        }
    }

    public func setup(_ canvasIdentifiedObjects:CanvasIdentifiedObject...) {
        setup(canvasIdentifiedObjects)
    }

    public func canvasSetSize(size:Size) {
        let command = "canvasSetSize|\(size.width)|\(size.height)"
        pendingCommandList.append(command)
    }

    // MARK: ********** Internal **********

    // In some cases we need integers from strings but some browsers transmit doubles
    internal func intFromDoubleString(_ s:String) -> Int? {
        if let d = Double(s) {
            return Int(d)
        } else {
            return nil
        }
    }
    
    internal func processCommands(context: ChannelHandlerContext, webSocketHandler:WebSocketHandler) {
        if pendingCommandList.count > 0 {
            let allCommands = pendingCommandList.joined(separator:"||")
            webSocketHandler.send(context: context, text:allCommands)
            pendingCommandList.removeAll()
        } else {
            let secondsSincePreviousPing = -Int(mostRecentPingTime.timeIntervalSinceNow)
            if (secondsSincePreviousPing > Canvas.minimumSecondsBeforePing) {
                webSocketHandler.send(context: context, text:"ping")
                mostRecentPingTime = Date()
            }
        }
    }
    
    internal func ready(context: ChannelHandlerContext, webSocketHandler:WebSocketHandler) {
        painter.setup(canvas:self)
        processCommands(context: context, webSocketHandler:webSocketHandler)
    }

    internal func recurring(context: ChannelHandlerContext, webSocketHandler:WebSocketHandler) {
        painter.calculate(canvasId:self.canvasId, canvasSize:canvasSize)
        painter.render(canvas:self)
        processCommands(context: context, webSocketHandler:webSocketHandler)
    }

    internal func reception(context: ChannelHandlerContext, webSocketHandler:WebSocketHandler, text:String) {
        var commandAndArguments = text.components(separatedBy:"|")
        if commandAndArguments.count > 0 {
            let command = commandAndArguments.removeFirst()
            let arguments = commandAndArguments
            switch (command) {
                // Mouse events
            case "onClick":
                receptionOnClick(arguments:arguments)
            case "onMouseDown":
                receptionOnMouseDown(arguments:arguments)
            case "onMouseUp":
                receptionOnMouseUp(arguments:arguments)
            case "onWindowMouseUp":
                receptionOnWindowMouseUp(arguments:arguments)
            case "onMouseMove":
                receptionOnMouseMove(arguments:arguments)

                // Key events
            case "onKeyDown":
                receptionOnKeyDown(arguments:arguments)
            case "onKeyUp":
                receptionOnKeyUp(arguments:arguments)

                // Image events
            case "onImageError":
                receptionOnImageError(arguments:arguments)
            case "onImageLoaded":
                receptionOnImageLoaded(arguments:arguments)
            case "onImageProcessed":
                receptionOnImageProcessed(arguments:arguments)

                // Gradient events
            case "onLinearGradientLoaded":
                receptionOnLinearGradientLoaded(arguments:arguments)
            case "onRadialGradientLoaded":
                receptionOnRadialGradientLoaded(arguments:arguments)
            case "onLinearGradientProcessed":
                receptionOnLinearGradientProcessed(arguments:arguments)
            case "onRadialGradientProcessed":
                receptionOnRadialGradientProcessed(arguments:arguments)

                // Pattern events
            case "onPatternLoaded":
                receptionOnPatternLoaded(arguments:arguments)
            case "onPatternProcessed":
                receptionOnPatternProcessed(arguments:arguments)

                // Audio events
            case "onAudioError":
                receptionOnAudioError(arguments:arguments)
            case "onAudioLoaded":
                receptionOnAudioLoaded(arguments:arguments)
            case "onAudioProcessed":
                receptionOnAudioProcessed(arguments:arguments)

                // Text events
            case "onTextMetricLoaded":
                receptionOnTextMetricLoaded(arguments:arguments)
            case "onTextMetricProcessed":
                receptionOnTextMetricProcessed(arguments:arguments)
            case "onTextMetricReady":
                receptionOnTextMetricReady(arguments:arguments)

                // Resize events
            case "onCanvasResize":
                receptionOnCanvasResize(arguments:arguments)
            case "onWindowResize":
                receptionOnWindowResize(arguments:arguments)
            default:
                print("ERROR: Unknown command received: \(command)")
            }
        }
    }

    internal func receptionOnClick(arguments:[String]) {
        // In some cases (from some browsers) a Double is received
        guard arguments.count == 2,
              let x = intFromDoubleString(arguments[0]),
              let y = intFromDoubleString(arguments[1]) else {
            print("ERROR: onClick requires exactly two integer or double arguments")
            return
        }
        painter.onClick(location:Point(x:x, y:y))
    }

    internal func receptionOnMouseDown(arguments:[String]) {
        guard arguments.count == 2,
              let x = intFromDoubleString(arguments[0]),
              let y = intFromDoubleString(arguments[1]) else {
            print("ERROR: onMouseDown requires exactly two integer or double arguments")
            return
        }
        painter.onMouseDown(location:Point(x:x, y:y))
    }

    internal func receptionOnMouseUp(arguments:[String]) {
        guard arguments.count == 2,
              let x = intFromDoubleString(arguments[0]),
              let y = intFromDoubleString(arguments[1]) else {
            print("ERROR: onMouseUp requires exactly two integer or double arguments")
            return
        }
        painter.onMouseUp(location:Point(x:x, y:y))
    }

    internal func receptionOnWindowMouseUp(arguments:[String]) {
        guard arguments.count == 2,
              let x = intFromDoubleString(arguments[0]),
              let y = intFromDoubleString(arguments[1]) else {
            print("ERROR: onWindowMouseUp requires exactly two integer or double arguments")
            return
        }
        painter.onWindowMouseUp(location:Point(x:x, y:y))
    }

    internal func receptionOnMouseMove(arguments:[String]) {
        guard arguments.count == 2,
              let x = intFromDoubleString(arguments[0]),
              let y = intFromDoubleString(arguments[1]) else {
            print("ERROR: onMouseMove requires exactly two integer or double arguments")
            return
        }
        painter.onMouseMove(location:Point(x:x, y:y))
    }

    internal func receptionOnKeyDown(arguments:[String]) {
        guard arguments.count == 6,
              let ctrlKey = Bool(arguments[2]),
              let shiftKey = Bool(arguments[3]),
              let altKey = Bool(arguments[4]),
              let metaKey = Bool(arguments[5]) else {
            print("ERROR: onKeyDown requires exactly six arguments (String, String, Bool, Bool, Bool, Bool)")
            return
        }
        let key = arguments[0]
        let code = arguments[1]
        
        painter.onKeyDown(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)
    }

    internal func receptionOnKeyUp(arguments:[String]) {
        guard arguments.count == 6,
              let ctrlKey = Bool(arguments[2]),
              let shiftKey = Bool(arguments[3]),
              let altKey = Bool(arguments[4]),
              let metaKey = Bool(arguments[5]) else {
            print("ERROR: onKeyUp requires exactly six arguments (String, String, Bool, Bool, Bool, Bool)")
            return
        }
        let key = arguments[0]
        let code = arguments[1]

        painter.onKeyUp(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)
    }

    internal func receptionOnImageError(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionInImageError: requires exactly one argment which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnImageError: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.resourceError)
    }

    internal func receptionOnImageLoaded(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnImageLoaded requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnImageLoaded: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.ready)
    }

    internal func receptionOnImageProcessed(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnImageProcessed requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnImageProcessed: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.processedByClient)
    }

    
    internal func receptionOnLinearGradientProcessed(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnLinearGradientProcessed requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnLinearGradientProcessed: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.processedByClient)
    }

    internal func receptionOnLinearGradientLoaded(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnLinearGradientLoaded requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnLinearGradientLoaded: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.ready)
    }

    
    internal func receptionOnRadialGradientProcessed(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnRadialGradientProcessed requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnRadialGradientProcessed: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.processedByClient)
    }

    internal func receptionOnRadialGradientLoaded(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnRadialGradientLoaded requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnRadialGradientLoaded: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.ready)
    }

    internal func receptionOnPatternProcessed(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnPatternProcessed requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnPatternProcessed: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.processedByClient)
    }

    internal func receptionOnPatternLoaded(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnPatternLoaded requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnPatternLoaded: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.ready)
    }

    internal func receptionOnAudioError(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnAudioError: requires exactly one argment which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnAudioError: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.resourceError)
    }

    internal func receptionOnAudioLoaded(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnAudioLoaded requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnAudioLoaded: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.ready)
    }

    internal func receptionOnAudioProcessed(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnAudioProcessed requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnImageProcessed: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.processedByClient)
    }

    internal func receptionOnTextMetricLoaded(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnTextMetricLoaded requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnTextMetricLoaded: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.ready)
    }

    internal func receptionOnTextMetricProcessed(arguments:[String]) {
        guard arguments.count == 1,
              let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnTextMetricProcessed requires exactly one argument which must be a valid UUID.")
            return
        }

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnImageProcessed: Object with id \(id.uuidString) was not found.")
            return
        }
        identifiedObject.setState(.processedByClient)
    }

    internal func receptionOnTextMetricReady(arguments:[String]) {
        guard arguments.count == 13 else {
            print("ERROR: receptionOnTextMetricReady requires exactly 13 arguments")
            return
        }

        guard let id = UUID(uuidString:arguments[0]) else {
            print("ERROR: receptionOnTextMetricReady argument 1 must be a UUID")
            return
        }

        guard let width                     = Double(arguments[ 1]),
              let actualBoundingBoxLeft     = Double(arguments[ 2]),
              let actualBoundingBoxRight    = Double(arguments[ 3]),
              let fontBoundingBoxAscent     = Double(arguments[ 4]),
              let fontBoundingBoxDescent    = Double(arguments[ 5]),
              let actualBoundingBoxAscent   = Double(arguments[ 6]),
              let actualBoundingBoxDescent  = Double(arguments[ 7]),
              let emHeightAscent            = Double(arguments[ 8]),
              let emHeightDescent           = Double(arguments[ 9]),
              let hangingBaseline           = Double(arguments[10]),
              let alphabeticBaseline        = Double(arguments[11]),
              let ideographicBaseline       = Double(arguments[12])
        else {
            print("ERROR: receptionOnTextMetricReady arguments 2 through 13 must be Doubles")
            return
        }

        let metrics = TextMetric.Metrics(
          width: width,
          actualBoundingBoxLeft: actualBoundingBoxLeft,
          actualBoundingBoxRight: actualBoundingBoxRight,
          fontBoundingBoxAscent: fontBoundingBoxAscent,
          fontBoundingBoxDescent: fontBoundingBoxDescent,
          actualBoundingBoxAscent: actualBoundingBoxAscent,
          actualBoundingBoxDescent: actualBoundingBoxDescent,
          emHeightAscent: emHeightAscent,
          emHeightDescent: emHeightDescent,
          hangingBaseline: hangingBaseline,
          alphabeticBaseline: alphabeticBaseline,
          ideographicBaseline: ideographicBaseline)

        guard let identifiedObject = identifiedObjectDictionary[id] else {
            print("ERROR: receptionOnTextMetricReady: Object with id \(id.uuidString) was not found.")
            return
        }

        guard let textMetric = identifiedObject as? TextMetric else {
            print("ERROR: receptionOnTextMetricReady: Object with id \(id.uuidString) is not a TextMetric object.")
            return
        }

        textMetric.setMetrics(metrics:metrics)
    }

    internal func receptionOnCanvasResize(arguments:[String]) {
        guard arguments.count == 2,
              let width = Double(arguments[0]),
              let height = Double(arguments[1]) else {
            print("ERROR: onCanvasResize requires exactly two double arguments")
            return
        }
        canvasSize = Size(width:Int(width), height:Int(height))
        painter.onCanvasResize(size:canvasSize!);
    }
    
    internal func receptionOnWindowResize(arguments:[String]) {
        guard arguments.count == 2,
              let width = Double(arguments[0]),
              let height = Double(arguments[1]) else {
            print("ERROR: onWindowResize requires exactly two double arguments")
            return
        }
        windowSize = Size(width:Int(width), height:Int(height))
        painter.onWindowResize(size:windowSize!)
    }
    
    internal func nextRecurringInterval() -> TimeAmount {
        let framesPerSecond = painter.framesPerSecond()
        let intervalInSeconds = 1.0 / Double(framesPerSecond)
        let intervalInMilliSeconds = Int64(intervalInSeconds * 1_000)
        return .milliseconds(intervalInMilliSeconds)
    }
    
}
