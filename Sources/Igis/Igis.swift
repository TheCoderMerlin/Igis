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

public class Igis {
    let resourcePath : String!
    let resourceDirectory : URL!
    let localHost : String!
    let localPort : Int!

    // Use parameters if specified, otherwise fallback to environment, otherwise fail
    public init(resourcePath:String?=nil, localHost:String?=nil, localPort:Int?=nil) {
        self.resourcePath = resourcePath ?? Igis.detectedResourcePath() ?? ProcessInfo.processInfo.environment["IGIS_RESOURCE_PATH"]
        guard self.resourcePath != nil else {
            fatalError("resourcePath not specified, and environment variable 'IGIS_RESOURCE_PATH' not set")
        }
        self.resourceDirectory = URL(fileURLWithPath:self.resourcePath.expandingTildeInPath, isDirectory:true)
        print("Loading resources from \(resourceDirectory.path)")

        self.localHost = localHost ?? ProcessInfo.processInfo.environment["IGIS_LOCAL_HOST"]
        guard self.localHost != nil else {
            fatalError("localHost not specified and environment variable 'IGIS_LOCAL_HOST' not set")
        }

        self.localPort = localPort ?? Int(ProcessInfo.processInfo.environment["IGIS_LOCAL_PORT"] ?? "")
        guard self.localPort != nil else {
            fatalError("localPort not specified and environment variable 'IGIS_LOCAL_PORT' not set or invalid")
        }
    }

    public func run(painterType:PainterProtocol.Type) throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let upgrader = WebSocketUpgrader(shouldUpgrade: { (head: HTTPRequestHead) in HTTPHeaders() },
                                         upgradePipelineHandler: { (channel: Channel, _: HTTPRequestHead) in
                                             return channel.pipeline.add(handler: WebSocketHandler(canvas:Canvas(painter:painterType.init())))
                                         })

        let bootstrap = ServerBootstrap(group: group)
        // Specify backlog and enable SO_REUSEADDR for the server itself
          .serverChannelOption(ChannelOptions.backlog, value: 256)
          .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        // Set the handlers that are applied to the accepted Channels
          .childChannelInitializer { channel in
              let httpHandler = HTTPHandler(resourceDirectory:self.resourceDirectory)
              let config: HTTPUpgradeConfiguration = (
                upgraders: [ upgrader ], 
                completionHandler: { _ in 
                    channel.pipeline.remove(handler: httpHandler, promise: nil)
                }
              )
              return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).then {
                  channel.pipeline.add(handler: httpHandler)
              }
          }

        // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
          .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
          .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        defer {
            try! group.syncShutdownGracefully()
        }
        let channel = try { () -> Channel in
            return try bootstrap.bind(host: localHost, port: localPort).wait()
        }()

        guard let localAddress = channel.localAddress else {
            fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
        }
        print("Server started and listening on \(localAddress)")

        // This will never unblock as we don't close the ServerChannel
        try channel.closeFuture.wait()

        print("Server closed")
    } // func main

    private static func detectedResourcePath() -> String? {
        // Start with the location of the dynamic library as specified in the environment
        // We'll either be in the .build/debug or .build/release
        // We move up two directories and then into Sources/Igis/Resources
        // DYLIB_Igis_PATH=/usr/local/lib/merlin/Igis-1.0.9/Igis/.build/debug

        guard let igisLibraryPath = ProcessInfo.processInfo.environment["DYLIB_Igis_PATH"] else {
            print("DYLIB_Igis_PATH undefined")
            return nil
        }
        var url = URL(fileURLWithPath:igisLibraryPath, isDirectory:false)   // /usr/local/lib/merlin/Igis-1.0.9/Igis/.build/debug
        url.deleteLastPathComponent()                                       // /usr/local/lib/merlin/Igis-1.0.9/Igis/.build
        url.deleteLastPathComponent()                                       // /usr/local/lib/merlin/Igis-1.0.9/Igis/
        url.appendPathComponent("Sources")                                  // /usr/local/lib/merlin/Igis-1.0.9/Igis/Sources
        url.appendPathComponent("Igis")                                     // /usr/local/lib/merlin/Igis-1.0.9/Igis/Sources/Igis
        url.appendPathComponent("Resources")                                // /usr/local/lib/merlin/Igis-1.0.9/Igis/Sources/Igis/Resources
        
        guard FileManager.default.fileExists(atPath:url.path) else {
            print("Expected resource path not found at \(url.path)")
            return nil
        }

        return url.path
    }

} // class Igis

