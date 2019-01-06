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
import Foundation
import Dispatch
import NIO
import NIOHTTP1
import NIOWebSocket

final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private var resourceDirectory:URL

    init(resourceDirectory:URL) {
        self.resourceDirectory = resourceDirectory
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let requestPart = self.unwrapInboundIn(data)
        guard case .head(let head) = requestPart else {
            return
        }
        
        // GETs only.
        guard case .GET = head.method else {
            self.respondError(ctx: ctx, status:.methodNotAllowed)
            return
        }

        // The URI will (should) point to the desired resource, a file located in the "Resources" directory
        var fileURL = resourceDirectory.appendingPathComponent(head.uri, isDirectory: false)
        fileURL.standardize()
        let filePath = fileURL.path
        guard FileManager.default.fileExists(atPath:filePath) else {
            print("Requested missing file at \(filePath)")
            self.respondError(ctx:ctx, status:.notFound)
            return
        }

        // Only three file types are currently supported
        let suffix = fileURL.pathExtension.lowercased()
        var mimeType : String
        switch suffix {
        case "html":
            mimeType = "text/html"
        case "css":
            mimeType = "text/css"
        case "js":
            mimeType = "text/javascript"
        default:
            print("Unexpected file suffix in \(filePath)")
            self.respondError(ctx:ctx, status:.notImplemented)
            return
        }
        

        // Load the requested file
        var contents : String
        do {
            contents = try String(contentsOf:fileURL, encoding:.utf8)
        } catch (let error) {
            print("Failed to load file \(filePath) because \(error)")
            self.respondError(ctx:ctx, status:.internalServerError)
            return
        }

        // Create the buffer for the response body
        var buffer = ctx.channel.allocator.buffer(capacity: contents.utf8.count)
        buffer.write(string: contents)
        
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: mimeType)
        headers.add(name: "Content-Length", value: String(buffer.readableBytes))
        headers.add(name: "Connection", value: "close")
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
        ctx.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        ctx.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        ctx.write(self.wrapOutboundOut(.end(nil))).whenComplete {
            ctx.close(promise: nil)
        }
        ctx.flush()
    }

    private func respondError(ctx: ChannelHandlerContext, status:HTTPResponseStatus) {
        var headers = HTTPHeaders()
        headers.add(name: "Connection", value: "close")
        headers.add(name: "Content-Length", value: "0")
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
        ctx.write(self.wrapOutboundOut(.head(head)), promise: nil)
        ctx.write(self.wrapOutboundOut(.end(nil))).whenComplete {
            ctx.close(promise: nil)
        }
        ctx.flush()
    }
}
