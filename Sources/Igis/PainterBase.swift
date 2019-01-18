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

/*     
   This MAY be used as a base class that fulfills the PainterProtocol,
   essentially acting as a stub for which only selected functions may
   be overridden.    
*/
  
public class PainterBase : PainterProtocol {
    public required init() {
    }

    public func setup(canvas:Canvas) {
    }
    
    public func update(canvas:Canvas) {
    }
    
    public func onClick(canvas:Canvas, location:Point) {
    }
    
    public func onMouseDown(canvas:Canvas, location:Point) {
    }
    
    public func onMouseUp(canvas:Canvas, location:Point) {
    }
    
    public func onMouseMove(canvas:Canvas, location:Point) {
    }
}
