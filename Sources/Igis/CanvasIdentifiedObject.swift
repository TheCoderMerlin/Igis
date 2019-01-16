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
    public private(set) var isSetup = false
    public private(set) var isLoaded = false

    
    internal func setupCommand() -> String {
        fatalError("setupCommand() invoked on CanvasIdentifiedObject")
    }

    internal func notifyObjectSetupComplete() {
        isSetup = true
    }

    internal func notifyObjectLoadComplete() {
        isLoaded = true
    }
}
