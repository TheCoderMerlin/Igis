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

// Reference:  https://github.com/apple/swift-nio/blob/master/Sources/NIOWebSocketServer/main.swift
import Dispatch
import NIO
import NIOHTTP1
import NIOWebSocket


public final class WebSocketHandler: ChannelInboundHandler {
    public typealias InboundIn = WebSocketFrame
    public typealias OutboundOut = WebSocketFrame

    private var awaitingClose: Bool = false
    private let canvas : Canvas

    init(canvas:Canvas) {
        self.canvas = canvas
    }

    public func handlerAdded(ctx: ChannelHandlerContext) {
        let interval = canvas.nextRecurringInterval()
        ctx.eventLoop.scheduleTask(in: interval, {self.recurringCallback(ctx: ctx)})
        canvas.ready(ctx:ctx, webSocketHandler:self)
    }

    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)

        switch frame.opcode {
        case .connectionClose:
            self.receivedClose(ctx: ctx, frame: frame)
        case .ping:
            self.pong(ctx: ctx, frame: frame)
        case .unknownControl, .unknownNonControl:
            self.closeOnError(ctx: ctx)
        case .text:
            var data = frame.unmaskedData
            let text = data.readString(length: data.readableBytes) ?? ""
            canvas.reception(ctx:ctx, webSocketHandler:self, text:text)
        default:
            // We ignore all other frames.
            break
        }
    }

    public func recurringCallback(ctx: ChannelHandlerContext) {
        canvas.recurring(ctx:ctx, webSocketHandler:self)
        let interval = canvas.nextRecurringInterval()
        ctx.eventLoop.scheduleTask(in: interval, {self.recurringCallback(ctx: ctx)})
    }

    public func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }

    public func send(ctx: ChannelHandlerContext, text:String) {
        guard ctx.channel.isActive else { return }
        guard !self.awaitingClose else { return }

        var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)

        let frame = WebSocketFrame(fin:true, opcode:.text, data:buffer)
        ctx.writeAndFlush(self.wrapOutboundOut(frame)).whenFailure { (_:Error) in
            ctx.close(promise:nil)
        }
    }

    private func receivedClose(ctx: ChannelHandlerContext, frame: WebSocketFrame) {
        // Handle a received close frame. In websockets, we're just going to send the close
        // frame and then close, unless we already sent our own close frame.
        if awaitingClose {
            // Cool, we started the close and were waiting for the user. We're done.
            ctx.close(promise: nil)
        } else {
            // This is an unsolicited close. We're going to send a response frame and
            // then, when we've sent it, close up shop. We should send back the close code the remote
            // peer sent us, unless they didn't send one at all.
            var data = frame.unmaskedData
            let closeDataCode = data.readSlice(length: 2) ?? ctx.channel.allocator.buffer(capacity: 0)
            let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
            _ = ctx.write(self.wrapOutboundOut(closeFrame)).map { () in
                ctx.close(promise: nil)
            }
        }
    }

    private func pong(ctx: ChannelHandlerContext, frame: WebSocketFrame) {
        var frameData = frame.data
        let maskingKey = frame.maskKey

        if let maskingKey = maskingKey {
            frameData.webSocketUnmask(maskingKey)
        }

        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
        ctx.write(self.wrapOutboundOut(responseFrame), promise: nil)
    }

    private func closeOnError(ctx: ChannelHandlerContext) {
        // We have hit an error, we want to close. We do that by sending a close frame and then
        // shutting down the write side of the connection.
        var data = ctx.channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .protocolError)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        ctx.write(self.wrapOutboundOut(frame)).whenComplete {
            ctx.close(mode: .output, promise: nil)
        }
        awaitingClose = true
    }
}

