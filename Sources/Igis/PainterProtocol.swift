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

public protocol PainterProtocol {
    init()

    func framesPerSecond() -> Int
    
    func setup(canvas:Canvas)
    func update(canvas:Canvas)

    func onCanvasResize(size:Size)
    func onWindowResize(size:Size)
    
    func onClick(location:Point)
    func onMouseDown(location:Point)
    func onMouseUp(location:Point)
    func onMouseMove(location:Point)

    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)

}
