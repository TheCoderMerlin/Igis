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
  
public class CanvasIdentifiedObject : CanvasObject {

    internal let id = UUID()

    // Object state; proceeds from top to bottom
    internal enum State : Int {
        case pendingTransmission   // Not yet transmitted
        case transmissionQueued    // Transmission queued for client
        case processedByClient     // Processed by client
        case resourceError         // Resource is not available on client
        case ready                 // Ready for use on client
    }
    private var state : State = .pendingTransmission
    
    internal func setupCommand() -> String {
        fatalError("setupCommand() invoked on CanvasIdentifiedObject")
    }

    internal func setState(_ newState:State) {
        if newState.rawValue <= state.rawValue {
            print("ERROR: State of object with id \(id) is regressing from \(state) to \(newState).")
        }
        state = newState
        print("State transition from \(state) to \(newState)")
    }

    public var isReady : Bool {
        return state == .ready
    }

    public var isResourceError : Bool {
        return state == .resourceError
    }
    
}
