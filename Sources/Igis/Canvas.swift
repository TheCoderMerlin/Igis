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

import Foundation
import NIO

public class Canvas {

    private static var nextCanvasId : Int = 0
    private let painter : PainterProtocol
    private var pendingCommandList = [String]()
    private var identifiedObjectDictionary = [UUID:CanvasIdentifiedObject]()

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

    public func paint(_ canvasObjects:CanvasObject...) {
        for canvasObject in canvasObjects {
            let command = canvasObject.canvasCommand()
            pendingCommandList.append(command)
        }
    }

    public func setup(_ canvasIdentifiedObjects:CanvasIdentifiedObject...) {
        for canvasIdentifiedObject in canvasIdentifiedObjects {
            identifiedObjectDictionary[canvasIdentifiedObject.id] = canvasIdentifiedObject
            
            let command = canvasIdentifiedObject.setupCommand()
            pendingCommandList.append(command)
            
            canvasIdentifiedObject.setState(.transmissionQueued)
        }
    }

    public func canvasSetSize(size:Size) {
        let command = "canvasSetSize|\(size.width)|\(size.height)"
        pendingCommandList.append(command)
    }

    // MARK: ********** Internal **********
    internal func processCommands(ctx:ChannelHandlerContext, webSocketHandler:WebSocketHandler) {
        if pendingCommandList.count > 0 {
            let allCommands = pendingCommandList.joined(separator:"||")
            webSocketHandler.send(ctx:ctx, text:allCommands)
            pendingCommandList.removeAll()
        } else {
            webSocketHandler.send(ctx:ctx, text:"ping")
        }
    }
    
    internal func ready(ctx:ChannelHandlerContext, webSocketHandler:WebSocketHandler) {
        painter.setup(canvas:self)
        processCommands(ctx:ctx, webSocketHandler:webSocketHandler)
    }

    internal func recurring(ctx:ChannelHandlerContext, webSocketHandler:WebSocketHandler) {
        painter.calculate(canvasId:self.canvasId, canvasSize:canvasSize)
        painter.paint(canvas:self)
        processCommands(ctx:ctx, webSocketHandler:webSocketHandler)
    }

    internal func reception(ctx:ChannelHandlerContext, webSocketHandler:WebSocketHandler, text:String) {
        var commandAndArguments = text.components(separatedBy:"|")
        if commandAndArguments.count > 0 {
            let command = commandAndArguments.removeFirst()
            let arguments = commandAndArguments
            switch (command) {
            case "onCanvasResize":
                receptionOnCanvasResize(arguments:arguments)
            case "onClick":
                receptionOnClick(arguments:arguments)
            case "onMouseDown":
                receptionOnMouseDown(arguments:arguments)
            case "onMouseUp":
                receptionOnMouseUp(arguments:arguments)
            case "onMouseMove":
                receptionOnMouseMove(arguments:arguments)
            case "onKeyDown":
                receptionOnKeyDown(arguments:arguments)
            case "onImageError":
                receptionOnImageError(arguments:arguments)
            case "onImageLoaded":
                receptionOnImageLoaded(arguments:arguments)
            case "onImageProcessed":
                receptionOnImageProcessed(arguments:arguments)
            case "onAudioProcessed":
                receptionOnAudioProcessed(arguments:arguments)
            case "onWindowResize":
                receptionOnWindowResize(arguments:arguments)
            default:
                do{}
            }
        }
    }

    internal func receptionOnClick(arguments:[String]) {
        guard arguments.count == 2,
              let x = Int(arguments[0]),
              let y = Int(arguments[1]) else {
            print("ERROR: onClick requires exactly two integer arguments")
            return
        }
        painter.onClick(location:Point(x:x, y:y))
    }

    internal func receptionOnMouseDown(arguments:[String]) {
        guard arguments.count == 2,
              let x = Int(arguments[0]),
              let y = Int(arguments[1]) else {
            print("ERROR: onMouseDown requires exactly two integer arguments")
            return
        }
        painter.onMouseDown(location:Point(x:x, y:y))
    }

    internal func receptionOnMouseUp(arguments:[String]) {
        guard arguments.count == 2,
              let x = Int(arguments[0]),
              let y = Int(arguments[1]) else {
            print("ERROR: onMouseUp requires exactly two integer arguments")
            return
        }
        painter.onMouseUp(location:Point(x:x, y:y))
    }

    internal func receptionOnMouseMove(arguments:[String]) {
        guard arguments.count == 2,
              let x = Int(arguments[0]),
              let y = Int(arguments[1]) else {
            print("ERROR: onMouseMove requires exactly two integer arguments")
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
        let intervalInMilliSeconds = Int(intervalInSeconds * 1_000)
        return .milliseconds(intervalInMilliSeconds)
    }
    
}
