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
  
open class PainterBase : PainterProtocol {
    public required init() {
    }

    open func setup(canvas:Canvas) {
    }
    
    open func update(canvas:Canvas) {
    }

    open func onCanvasResize(size:Size) {
    }

    open func onWindowResize(size:Size) {
    }
    
    open func onClick(location:Point) {
    }
    
    open func onMouseDown(location:Point) {
    }
    
    open func onMouseUp(location:Point) {
    }
    
    open func onMouseMove(location:Point) {
    }

    open func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
    }

}
