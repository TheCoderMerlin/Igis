/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2022 Tango Golf Digital, LLC
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

final class ColorTests : XCTestCase {
    let refrenceInput1     = "#FFFFFF"
    let referenceR1: UInt8 = 0xFF
    let referenceG1: UInt8 = 0xFF
    let referenceB1: UInt8 = 0xFF

    let refrenceInput2     = "#FF00FF"
    let referenceR2: UInt8 = 0xFF
    let referenceG2: UInt8 = 0x00
    let referenceB2: UInt8 = 0xFF

    let refrenceInput3     = "#F0FF00"
    let referenceR3: UInt8 = 0xF0
    let referenceG3: UInt8 = 0xFF
    let referenceB3: UInt8 = 0x00

    func testColorInput1() {
        let data = Color(refrenceInput1)

        XCTAssertEqual(data.red, referenceR1)
        XCTAssertEqual(data.green, referenceG1)
        XCTAssertEqual(data.blue, referenceB1)
    }


    func testColorInput2() {
        let data = Color(refrenceInput2)

        XCTAssertEqual(data.red, referenceR2)
        XCTAssertEqual(data.green, referenceG2)
        XCTAssertEqual(data.blue, referenceB2)
    }


    func testColorInput3() {
        let data = Color(refrenceInput3)

        XCTAssertEqual(data.red, referenceR3)
        XCTAssertEqual(data.green, referenceG3)
        XCTAssertEqual(data.blue, referenceB3)
    }
}
