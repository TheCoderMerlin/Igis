/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2020 Tango Golf Digital, LLC
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

import XCTest

@testable import Igis

final class RectTests : XCTestCase {

    let referenceX1 = -174738
    let referenceY1 =  383841
    let referenceW1 =   31385
    let referenceH1 =   78445

    let referenceX2 =  386758
    let referenceY2 = -846864
    let referenceW2 =   74734
    let referenceH2 =   19437

    let deltaWidth  = 7463
    let deltaHeight = 4752
    let delta       =  352

    func testZero() {
        let data = Rect.zero
        let referenceX = 0
        let referenceY = 0
        let referenceW = 0
        let referenceH = 0
        XCTAssertEqual(data.topLeft.x, referenceX)
        XCTAssertEqual(data.topLeft.y, referenceY)
        XCTAssertEqual(data.size.width, referenceW)
        XCTAssertEqual(data.size.height, referenceH)
    }

    func testInitDefault() {
        let data = Rect()
        let referenceX = 0
        let referenceY = 0
        let referenceW = 0
        let referenceH = 0
        XCTAssertEqual(data.topLeft.x, referenceX)
        XCTAssertEqual(data.topLeft.y, referenceY)
        XCTAssertEqual(data.size.width, referenceW)
        XCTAssertEqual(data.size.height, referenceH)
    }

    func testInitSize() {
        let data = Rect(size:Size(width:referenceW1, height:referenceH1))
        let referenceX = 0
        let referenceY = 0
        XCTAssertEqual(data.topLeft, Point(x:referenceX, y:referenceY))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))
    }

    func testInitTopLeftSize() {
        let data = Rect(topLeft:Point(x:referenceX1, y:referenceY1),
                        size:Size(width:referenceW1, height:referenceH1))
        XCTAssertEqual(data.topLeft, Point(x:referenceX1, y:referenceY1))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))
    }

    func testInitBottomLeftSize() {
        let data = Rect(bottomLeft:Point(x:referenceX1, y:referenceY1),
                        size:Size(width:referenceW1, height:referenceH1))
        XCTAssertEqual(data.bottomLeft, Point(x:referenceX1, y:referenceY1))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))
    }

    func testInitTopRightSize() {
        let data = Rect(topRight:Point(x:referenceX1, y:referenceY1),
                        size:Size(width:referenceW1, height:referenceH1))
        XCTAssertEqual(data.topRight, Point(x:referenceX1, y:referenceY1))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))
    }
    
    func testInitBottomRightSize() {
        let data = Rect(bottomRight:Point(x:referenceX1, y:referenceY1),
                        size:Size(width:referenceW1, height:referenceH1))
        XCTAssertEqual(data.bottomRight, Point(x:referenceX1, y:referenceY1))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))
    }
    
    func testLocal() {
        let source = Rect(topLeft:Point(x:referenceX1, y:referenceY1),
                          size:Size(width:referenceW1, height:referenceH1))
        let origin = Rect(topLeft:Point(x:referenceX2, y:referenceY2),
                          size:Size(width:referenceW2, height:referenceH2))
        let data = source.local(to:origin)
        XCTAssertEqual(data.topLeft, Point(x:referenceX1-referenceX2, y:referenceY1-referenceY2))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))
    }

    // TODO: Add tests for containment

    func testLeftRightTopBottom() {
        var data = Rect()
        data.left = referenceX1
        data.right = referenceX1 + referenceW1
        data.top = referenceY1
        data.bottom = referenceY1 + referenceH1
        XCTAssertEqual(data.left, referenceX1)
        XCTAssertEqual(data.right, referenceX1 + referenceW1)
        XCTAssertEqual(data.top, referenceY1)
        XCTAssertEqual(data.bottom, referenceY1 + referenceH1)
        XCTAssertEqual(data.topLeft, Point(x:referenceX1, y:referenceY1))
        XCTAssertEqual(data.size, Size(width:referenceW1, height:referenceH1))        
    }

    func testInflateSize() {
        var data = Rect(topLeft:Point(x:referenceX1, y:referenceY1),
                        size:Size(width:referenceW1, height:referenceH1))
        data.inflate(by: Size(width:deltaWidth, height:deltaHeight))
        XCTAssertEqual(data.left, referenceX1 - deltaWidth)
        XCTAssertEqual(data.right, referenceX1 + referenceW1 + deltaWidth)
        XCTAssertEqual(data.top, referenceY1 - deltaHeight)
        XCTAssertEqual(data.bottom, referenceY1 + referenceH1 + deltaHeight)
    }

    func testInflateInt() {
        var data = Rect(topLeft:Point(x:referenceX1, y:referenceY1),
                        size:Size(width:referenceW1, height:referenceH1))
        data.inflate(by: delta)
        XCTAssertEqual(data.left, referenceX1 - delta)
        XCTAssertEqual(data.right, referenceX1 + referenceW1 + delta)
        XCTAssertEqual(data.top, referenceY1 - delta)
        XCTAssertEqual(data.bottom, referenceY1 + referenceH1 + delta)
    }

}
