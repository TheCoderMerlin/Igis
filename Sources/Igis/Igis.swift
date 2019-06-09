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
        // Begin with the current directory, moving upwards, until "Package.swift" is found
        // or the root directory is reached
        // Then, find the resource directory from that point by descending via ".build/checkouts/Igis/Sources/Igis/Resources"
        let packageSwiftFilename = "Package.swift"
        let buildDirectoryName = ".build"
        let checkoutDirectoryName = "checkouts"
        let sourcesDirectoryName = "Sources"
        let igisDirectoryName = "Igis"
        let resourceDirectoryName = "Resources"
        var resourcePath : String? = nil

        var testDirectory = URL(fileURLWithPath:FileManager.default.currentDirectoryPath, isDirectory:true)
        var testURL = testDirectory.appendingPathComponent(packageSwiftFilename, isDirectory:false)
        testURL.standardize()
        
        while !FileManager.default.fileExists(atPath:testURL.path)  && testDirectory.pathComponents.count > 1 {
            testDirectory.deleteLastPathComponent()
            testURL = testDirectory.appendingPathComponent(packageSwiftFilename, isDirectory:false)
            testURL.standardize()
        }

        // At this point, either we found the file or have reached the root directory and have no other place to look
        if FileManager.default.fileExists(atPath:testURL.path) {
            print("Found \(packageSwiftFilename) at: \(testURL.path)")

            // At this point, we should be able to find a parallel directory ".build"
            let buildDirectory = testDirectory.appendingPathComponent(buildDirectoryName, isDirectory:true)
            guard FileManager.default.fileExists(atPath:buildDirectory.path) else {
                print("\(buildDirectory.path) not found")
                return nil
            }

            let checkoutDirectory = buildDirectory.appendingPathComponent(checkoutDirectoryName, isDirectory:true)
            guard FileManager.default.fileExists(atPath:checkoutDirectory.path) else {
                print("\(checkoutDirectory.path) not found")
                return nil
            }

            let igisRepositoryDirectory = checkoutDirectory.appendingPathComponent(igisDirectoryName, isDirectory:true)
            guard FileManager.default.fileExists(atPath:igisRepositoryDirectory.path) else {
                print("\(igisRepositoryDirectory.path) not found")
                return nil
            }
            

            let sourcesDirectory = igisRepositoryDirectory.appendingPathComponent(sourcesDirectoryName, isDirectory:true)
            guard FileManager.default.fileExists(atPath:sourcesDirectory.path) else {
                print("\(sourcesDirectory.path) not found")
                return nil
            }

            let igisDirectory = sourcesDirectory.appendingPathComponent(igisDirectoryName, isDirectory:true)
            guard FileManager.default.fileExists(atPath:igisDirectory.path) else {
                print("\(igisDirectory.path) not found")
                return nil
            }

            let resourceDirectory = igisDirectory.appendingPathComponent(resourceDirectoryName, isDirectory:true)
            guard FileManager.default.fileExists(atPath:resourceDirectory.path) else {
                print("\(resourceDirectory.path) not found")
                return nil
            }
            resourcePath = resourceDirectory.path
            
        } else {
            print("\(packageSwiftFilename) not found")
        }

        return resourcePath
    }

} // class Igis

