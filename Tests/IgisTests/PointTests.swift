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

final class PointTests : XCTestCase {

    let referenceX1 = -179843
    let referenceY1 =  274970
    
    let referenceX2 =  239574
    let referenceY2 = -893483

 
    func testZero() {
        let data = Point.zero
        let referenceX = 0
        let referenceY = 0
        XCTAssertEqual(data.x, referenceX)
        XCTAssertEqual(data.y, referenceY)
    }

    func testInitDefault() {
        let data = Point()
        let referenceX = 0
        let referenceY = 0
        XCTAssertEqual(data.x, referenceX)
        XCTAssertEqual(data.y, referenceY)
    }
    
    func testInitXY() {
        let data = Point(x: referenceX1, y: referenceY1)
        XCTAssertEqual(data.x, referenceX1)
        XCTAssertEqual(data.y, referenceY1)
    }

    func testInitDoublePoint() {
        let data = Point(DoublePoint(x:Double(referenceX1), y:Double(referenceY1)))
        XCTAssertEqual(data.x, referenceX1)
        XCTAssertEqual(data.y, referenceY1)
    }

    func testDistanceSquared() {
        let point1 = Point(x:referenceX1, y:referenceY1)
        let point2 = Point(x:referenceX2, y:referenceY2)
        let deltaX = referenceX2 - referenceX1
        let deltaY = referenceY2 - referenceY1
        let deltaXSquared = deltaX * deltaX
        let deltaYSquared = deltaY * deltaY
        let reference = deltaXSquared + deltaYSquared
        
        let data1 = point1.distanceSquared(to:point2)
        let data2 = point2.distanceSquared(to:point1)

        XCTAssertEqual(data1, reference)
        XCTAssertEqual(data2, reference)
    }

    func testDistance() {
        let point1 = Point(x:referenceX1, y:referenceY1)
        let point2 = Point(x:referenceX2, y:referenceY2)
        let deltaX = referenceX2 - referenceX1
        let deltaY = referenceY2 - referenceY1
        let deltaXSquared = Double(deltaX * deltaX)
        let deltaYSquared = Double(deltaY * deltaY)
        let reference = (deltaXSquared + deltaYSquared).squareRoot()
        
        let data1 = point1.distance(to:point2)
        let data2 = point2.distance(to:point1)

        XCTAssertEqual(data1, reference)
        XCTAssertEqual(data2, reference)
    }

    func testDoublePoints() {
        let point1 = Point(x:referenceX1, y:referenceY1)
        let point2 = Point(x:referenceX2, y:referenceY2)
        let reference = [point1, point2]
        let doublePoint1 = DoublePoint(x:referenceX1, y:referenceY1)
        let doublePoint2 = DoublePoint(x:referenceX2, y:referenceY2)
        let data = Point.Points([doublePoint1, doublePoint2])

        XCTAssertEqual(data, reference)
    }

    func testEquivalenceOperator() {
        let reference = Point(x:referenceX1, y:referenceY1)
        let data1 = Point(x:referenceX1, y:referenceY1)
        let data2 = Point(x:referenceX2, y:referenceY2)

        XCTAssertTrue(data1 == reference)
        XCTAssertFalse(data2 == reference)
    }

    func testAdditionOperator() {
        let addend1 = Point(x:referenceX1, y:referenceY1)
        let addend2 = Point(x:referenceX2, y:referenceY2)
        let reference = Point(x:referenceX1 + referenceX2, y:referenceY1 + referenceY2)
        let data = addend1 + addend2

        XCTAssertEqual(data, reference)
    }

    func testCompoundAdditionOperator() {
        var data = Point(x:referenceX1, y:referenceY1)
        let addend = Point(x:referenceX2, y:referenceY2)
        data += addend
        let reference = Point(x: referenceX1 + referenceX2, y: referenceY1 + referenceY2)

        XCTAssertEqual(data, reference)
    }

    func testNegationOperator() {
        let data = -Point(x:referenceX1, y:referenceY1)
        let reference = Point(x: -referenceX1, y: -referenceY1)

        XCTAssertEqual(data, reference)
    }

    func testSubtractionOperator() {
        let minuend = Point(x: referenceX1, y: referenceY1)
        let subtrahend = Point(x: referenceX2, y: referenceY2)
        let data = minuend - subtrahend
        let reference = Point(x: referenceX1 - referenceX2, y: referenceY1 - referenceY2)

        XCTAssertEqual(data, reference)
    }

    func testCompoundSubtractionOperator() {
        var data = Point(x: referenceX1, y: referenceY1)
        let subtrahend = Point(x: referenceX2, y: referenceY2)
        data -= subtrahend
        let reference = Point(x: referenceX1 - referenceX2, y: referenceY1 - referenceY2)

        XCTAssertEqual(data, reference)
    }
    
}
