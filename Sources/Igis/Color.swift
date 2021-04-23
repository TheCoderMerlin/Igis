/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018,2020 CoderMerlin.com
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


public final class Color {
    public let style : String

    /// The red RGB value of the color
    public var red : UInt8 {
        let hex = String(style.suffix(6).prefix(2))
        return Color.decDigits(hex)
    }
    
    /// The green RGB value of the color
    public var green : UInt8 {
        let hex = String(style.suffix(4).prefix(2))
        return Color.decDigits(hex)
    }

    /// The blue RGB value of the color
    public var blue : UInt8 {
        let hex = String(style.suffix(2))
        return Color.decDigits(hex)
    }

    public enum Name : String, CaseIterable {
        case aliceblue = "#F0F8FF"
        case antiquewhite = "#FAEBD7"
        case aquamarine = "#7FFFD4"
        case azure = "#F0FFFF"
        case beige = "#F5F5DC"
        case bisque = "#FFE4C4"
        case black = "#000000"
        case blanchedalmond = "#FFEBCD"
        case blue = "#0000FF"
        case blueviolet = "#8A2BE2"
        case brown = "#A52A2A"
        case burlywood = "#DEB887"
        case cadetblue = "#5F9EA0"
        case chartreuse = "#7FFF00"
        case chocolate = "#D2691E"
        case coral = "#FF7F50"
        case cornflowerblue = "#6495ED"
        case cornsilk = "#FFF8DC"
        case crimson = "#DC143C"
        case cyan = "#00FFFF"
        case darkblue = "#00008B"
        case darkcyan = "#008B8B"
        case darkgoldenrod = "#B8860B"
        case darkgray = "#A9A9A9"
        case darkgreen = "#006400"
        case darkkhaki = "#BDB76B"
        case darkmagenta = "#8B008B"
        case darkolivegreen = "#556B2F"
        case darkorange = "#FF8C00"
        case darkorchid = "#9932CC"
        case darkred = "#8B0000"
        case darksalmon = "#E9967A"
        case darkseagreen = "#8FBC8F"
        case darkslateblue = "#483D8B"
        case darkslategray = "#2F4F4F"
        case darkturquoise = "#00CED1"
        case darkviolet = "#9400D3"
        case deeppink = "#FF1493"
        case deepskyblue = "#00BFFF"
        case dimgray = "#696969"
        case dodgerblue = "#1E90FF"
        case firebrick = "#B22222"
        case floralwhite = "#FFFAF0"
        case forestgreen = "#228B22"
        case gainsboro = "#DCDCDC"
        case ghostwhite = "#F8F8FF"
        case gold = "#FFD700"
        case goldenrod = "#DAA520"
        case gray = "#808080"
        case green = "#008000"
        case greenyellow = "#ADFF2F"
        case honeydew = "#F0FFF0"
        case hotpink = "#FF69B4"
        case indianred = "#CD5C5C"
        case indigo = "#4B0082"
        case ivory = "#FFFFF0"
        case khaki = "#F0E68C"
        case lavender = "#E6E6FA"
        case lavenderblush = "#FFF0F5"
        case lawngreen = "#7CFC00"
        case lemonchiffon = "#FFFACD"
        case lightblue = "#ADD8E6"
        case lightcoral = "#F08080"
        case lightcyan = "#E0FFFF"
        case lightgoldenrodyellow = "#FAFAD2"
        case lightgray = "#D3D3D3"
        case lightgreen = "#90EE90"
        case lightpink = "#FFB6C1"
        case lightsalmon = "#FFA07A"
        case lightseagreen = "#20B2AA"
        case lightskyblue = "#87CEFA"
        case lightslategray = "#778899"
        case lightsteelblue = "#B0C4DE"
        case lightyellow = "#FFFFE0"
        case lime = "#00FF00"
        case limegreen = "#32CD32"
        case linen = "#FAF0E6"
        case magenta = "#FF00FF"
        case maroon = "#800000"
        case mediumaquamarine = "#66CDAA"
        case mediumblue = "#0000CD"
        case mediumorchid = "#BA55D3"
        case mediumpurple = "#9370DB"
        case mediumseagreen = "#3CB371"
        case mediumslateblue = "#7B68EE"
        case mediumspringgreen = "#00FA9A"
        case mediumturquoise = "#48D1CC"
        case mediumvioletred = "#C71585"
        case midnightblue = "#191970"
        case mintcream = "#F5FFFA"
        case mistyrose = "#FFE4E1"
        case moccasin = "#FFE4B5"
        case navajowhite = "#FFDEAD"
        case navy = "#000080"
        case oldlace = "#FDF5E6"
        case olive = "#808000"
        case olivedrab = "#6B8E23"
        case orange = "#FFA500"
        case orangered = "#FF4500"
        case orchid = "#DA70D6"
        case palegoldenrod = "#EEE8AA"
        case palegreen = "#98FB98"
        case paleturquoise = "#AFEEEE"
        case palevioletred = "#DB7093"
        case papayawhip = "#FFEFD5"
        case peachpuff = "#FFDAB9"
        case peru = "#CD853F"
        case pink = "#FFC0CB"
        case plum = "#DDA0DD"
        case powderblue = "#B0E0E6"
        case purple = "#800080"
        case rebeccapurple = "#663399"
        case red = "#FF0000"
        case rosybrown = "#BC8F8F"
        case royalblue = "#4169E1"
        case saddlebrown = "#8B4513"
        case salmon = "#FA8072"
        case sandybrown = "#F4A460"
        case seagreen = "#2E8B57"
        case seashell = "#FFF5EE"
        case sienna = "#A0522D"
        case silver = "#C0C0C0"
        case skyblue = "#87CEEB"
        case slateblue = "#6A5ACD"
        case slategray = "#708090"
        case snow = "#FFFAFA"
        case springgreen = "#00FF7F"
        case steelblue = "#4682B4"
        case tan = "#D2B48C"
        case teal = "#008080"
        case thistle = "#D8BFD8"
        case tomato = "#FF6347"
        case turquoise = "#40E0D0"
        case violet = "#EE82EE"
        case wheat = "#F5DEB3"
        case white = "#FFFFFF"
        case whitesmoke = "#F5F5F5"
        case yellow = "#FFFF00"
        case yellowgreen = "#9ACD32"

        static let aqua = Name.cyan
        static let darkgrey = Name.darkgray
        static let darkslategrey = Name.darkslategray
        static let dimgrey = Name.dimgray
        static let fuchsia = Name.magenta
        static let grey = Name.gray
        static let lightgrey = Name.lightgray
        static let lightslategrey = Name.lightslategray
        static let slategrey = Name.slategray
    }

    public required init (red:UInt8, green:UInt8, blue:UInt8) {
        style = "#" + Color.hexDigits(red) + Color.hexDigits(green) + Color.hexDigits(blue)
    }

    public init(_ name:Name) {
        style = name.rawValue
    }

    // Calculates a new Color of certain percentage between this Color and another
    /// - Parameters:
    ///   - target: The target Color to which to calculate the new Color between
    ///   - percent: Value between 0 and 1 representing percentage
    /// - Returns: A new Color of percent between this Color and a target Color

    public func lerp(to target:Color, percent:Double) -> Self {
        let newRed = Double(red) + (Double(target.red) - Double(red)) * percent
        let newGreen = Double(green) + (Double(target.green) - Double(green)) * percent
        let newBlue = Double(blue) * (Double(target.blue) - Double(blue)) * percent
        return type(of:self).init(red:Color.forceUInt8(newRed), green:Color.forceUInt8(newGreen), blue:Color.forceUInt8(newBlue))
    }

    internal static func hexDigits(_ color:UInt8) -> String {
        var hexadecimal = String(color, radix:16)
        if hexadecimal.count < 2 {
            hexadecimal = "0" + hexadecimal
        }
        return hexadecimal
    }

    internal static func decDigits(_ color:String) -> UInt8 {
        guard let decimal = UInt8(color, radix:16) else {
            fatalError("hex value of \(color) doesn't conform to UInt8")
        }
        return decimal
    }

    internal static func forceUInt8(_ color:Double) -> UInt8 {
        if color > Double(UInt8.max) {
            return UInt8.max
        } else if color < Double(UInt8.min) {
            return UInt8.min
        }
        return UInt8(color)
    }
}
