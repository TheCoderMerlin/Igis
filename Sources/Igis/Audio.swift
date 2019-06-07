/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018,2019 Tango Golf Digital, LLC
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

public class Audio : CanvasIdentifiedObject {
    public let sourceURL : URL
    public let shouldLoop : Bool

    public enum Mode {
        case play
        case pause
    }
    public var mode : Mode

    public init(sourceURL:URL, shouldLoop:Bool = false) {
        self.sourceURL = sourceURL
        self.shouldLoop = shouldLoop
        self.mode = .play
    }

    internal override func canvasCommand() -> String {
        if !isReady {
            print("WARNING: canvasCommand requested on audio not yet ready. ID: \(id.uuidString).")
        }
        var commands : String = "setAudioMode|\(id.uuidString)|"
        switch mode {
        case .play:
            commands += "play"
        case .pause:
            commands += "pause"
        }
        return commands
    }

    internal override func setupCommand() -> String {
        let commands = "createAudio|\(id.uuidString)|\(sourceURL.absoluteString)|\(shouldLoop)"
        return commands
    }

}
