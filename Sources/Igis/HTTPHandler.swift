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

final class HTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private var resourceDirectory:URL

    init(resourceDirectory:URL) {
        self.resourceDirectory = resourceDirectory
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let requestPart = self.unwrapInboundIn(data)
        guard case .head(let head) = requestPart else {
            return
        }
        
        // GETs only.
        guard case .GET = head.method else {
            self.respondError(context: context, status:.methodNotAllowed)
            return
        }

        // The URI will (should) point to the desired resource, a file located in the "Resources" directory
        guard let url = URL(string:head.uri) else {
            print("WARNING: Specified url is not valid: \(head.uri)")
            self.respondError(context: context, status:.notFound)
            return
        }
        let fileURL = resourceDirectory.appendingPathComponent(url.path, isDirectory: false).standardizedFileURL
        let filePath = fileURL.path
        guard FileManager.default.fileExists(atPath:filePath) else {
            print("WARNING: Requested missing file at \(filePath)")
            self.respondError(context: context, status:.notFound)
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
            print("WARNING: Unexpected file suffix in \(filePath)")
            self.respondError(context: context, status:.notImplemented)
            return
        }
        

        // Load the requested file
        var contents : String
        do {
            contents = try String(contentsOf:fileURL, encoding:.utf8)
        } catch (let error) {
            print("WARNING: Failed to load file \(filePath) because \(error)")
            self.respondError(context: context, status:.internalServerError)
            return
        }

        // Create the buffer for the response body
        var buffer = context.channel.allocator.buffer(capacity: contents.utf8.count)
        buffer.writeString(contents)
        
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: mimeType)
        headers.add(name: "Content-Length", value: String(buffer.readableBytes))
        headers.add(name: "Connection", value: "close")
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        context.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        context.flush()
    }

    private func respondError(context: ChannelHandlerContext, status:HTTPResponseStatus) {
        var headers = HTTPHeaders()
        headers.add(name: "Connection", value: "close")
        headers.add(name: "Content-Length", value: "0")
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        context.flush()
    }
}
