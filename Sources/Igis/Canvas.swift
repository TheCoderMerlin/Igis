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

import NIO

public class Canvas {

    private let painter : PainterProtocol
    private var pendingCommandList = [String]()
    public private(set) var size : Size? = nil
    
    internal init(painter:PainterProtocol) {
        self.painter = painter
    }

    // MARK: ********** API **********

    public func paint(_ canvasObjects:CanvasObject...) {
        for canvasObject in canvasObjects {
            let command = canvasObject.canvasCommand()
            pendingCommandList.append(command)
        }
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
        painter.update(canvas:self)
        processCommands(ctx:ctx, webSocketHandler:webSocketHandler)
    }

    internal func reception(ctx:ChannelHandlerContext, webSocketHandler:WebSocketHandler, text:String) {
        var commandAndArguments = text.components(separatedBy:"|")
        if commandAndArguments.count > 0 {
            let command = commandAndArguments.removeFirst()
            let arguments = commandAndArguments
            switch (command) {
            case "onClick":
                receptionOnClick(arguments:arguments)
            case "onSetSize":
                receptionOnSetSize(arguments:arguments)
            default:
                do{}
            }
        }
        processCommands(ctx:ctx, webSocketHandler:webSocketHandler)
    }

    internal func receptionOnClick(arguments:[String]) {
        guard arguments.count == 2,
              let x = Int(arguments[0]),
              let y = Int(arguments[1]) else {
            print("ERROR: onClick requires exactly two integer arguments")
            return
        }
        painter.onClick(canvas:self, location:Point(x:x, y:y))
    }

    internal func receptionOnSetSize(arguments:[String]) {
        guard arguments.count == 2,
              let width = Double(arguments[0]),
              let height = Double(arguments[1]) else {
            print("ERROR: onSetSize requires exactly two double arguments")
            return
        }
        size = Size(width:Int(width), height:Int(height))
    }
    
    internal func nextRecurringInterval() -> TimeAmount {
        return .milliseconds(100)
    }
    
}
