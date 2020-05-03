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


/* This class is used to determine the metrics of the specified text in the
   specified font.  Unlike most other objects, rendering this object doesn't
   have any visible or audible effects in the browser.  Rather, the metrics
   for the given text are updated.
   As such, it's pointless to render this object unless a change has been
   made to the specified text.

   References: https://developer.mozilla.org/en-US/docs/Web/API/TextMetrics
               https://stackoverflow.com/questions/14836350/how-to-get-the-bounding-box-of-a-text-using-html5-canvas
 */
  
public class TextMetric : CanvasIdentifiedObject {

    public struct Metrics {
        public let width : Double
        public let actualBoundingBoxLeft : Double
        public let actualBoundingBoxRight : Double
        public let fontBoundingBoxAscent : Double?    // Not yet available in all browsers
        public let fontBoundingBoxDescent : Double?   // Not yet available in all browsers
        public let actualBoundingBoxAscent : Double
        public let actualBoundingBoxDescent : Double
        public let emHeightAscent : Double?           // Not yet available in all browsers
        public let emHeightDescent : Double?          // Not yet available in all browsers
        public let hangingBaseline : Double?          // Not yet available in all browsers
        public let alphabeticBaseline : Double?       // Not yet available in all browsers
        public let ideographicBaseline : Double?      // Not yet available in all browsers

        // Returns the actual bounding box used for the text at the specified location
        public func actualBoundingBox(location:Point = Point()) -> Rect {
            let left   =  Double(location.x) - abs(actualBoundingBoxLeft)   // Some browsers (Firefox 75.0) specify a negative value
            let top    =  Double(location.y) - actualBoundingBoxAscent
            let right  =  Double(location.x) + actualBoundingBoxRight
            let bottom =  Double(location.y) + actualBoundingBoxDescent

            let rect = Rect(topLeft:Point(x:Int(left), y:Int(top)),
                            size:Size(width:(Int(right - left)), height:(Int(bottom - top))))
            return rect
        }

        // Returns the font bounding box used for the text at the specified location
        // (This is more useful for user-entered text where the height of the line may change
        //  depending upon the characters entered)
        // NB: Some of the metrics are not yet universally available in all browsers,
        // in such cases the return value will be nil
        public func fontBoundingBox(location:Point = Point()) -> Rect? {
            if let fontBoundingBoxAscent = fontBoundingBoxAscent,
               let fontBoundingBoxDescent = fontBoundingBoxDescent {
                let left   =  Double(location.x) - abs(actualBoundingBoxLeft) // Some browsers (Firefox 75.0) specify a negative value
                let top    =  Double(location.y) - fontBoundingBoxAscent
                let right  =  Double(location.x) + actualBoundingBoxRight
                let bottom =  Double(location.y) + fontBoundingBoxDescent

                let rect = Rect(topLeft:Point(x:Int(left), y:Int(top)),
                                size:Size(width:(Int(right - left)), height:(Int(bottom - top))))
                return rect
            } else {
                return nil
            }
        }

    }

    // The text for which to obtain metrics
    // The actual result returned will depend not only on the text but also on the
    // font, alignment, and baseline
    public var text : String {
        willSet {
            pushMetrics()
        }
    }

    // The font used to calculate the metrics
    public var font : String? {
        willSet {
            pushMetrics()
        }
    }

    // The alignment used to calculate the metrics
    public var alignment : Text.Alignment? {
        willSet {
            pushMetrics()
        }
    }

    // The baseline used to calculate the metrics
    public var baseline : Text.Baseline? {
        willSet {
            pushMetrics()
        }
    }

    // The current metrics, set to nil whenever the text or font is changed
    public private(set) var currentMetrics  : Metrics? = nil

    // The previous metrics, set to currentMetrics whenever the text or font is changed
    public private(set) var previousMetrics : Metrics? = nil

    // The most recently available metrics
    public var mostRecentMetrics : Metrics? {
        return currentMetrics ?? previousMetrics
    }
    

    // Create a new TextMetric object from the specified text
    public init(text:String) {
        self.text = text
    }

    // Create a new TextMetric object from the specified Text object
    // This has the benefit of also setting the font, alignment, and baseline, if specified
    // in the text object
    public init(fromText:Text) {
        self.text      = fromText.text
        self.font      = fromText.font
        self.alignment = fromText.alignment
        self.baseline  = fromText.baseline
    }

    internal func pushMetrics() {
        // We preserve the current metrics (but don't overwrite the previous metrics with nil,
        // as might happen if multiple updates occur, for example setting text and font,
        // prior to receiving an update)
        if currentMetrics != nil {
            previousMetrics = currentMetrics
        }
        currentMetrics = nil
    }

    internal func setMetrics(metrics:Metrics) {
        currentMetrics = metrics
    }
    
    internal override func canvasCommand() -> String {
        var commands = String()
        
        if let font = font {
            commands += "font|\(font)||"
        }

        if let alignment = alignment {
            commands += "textAlign|"
            switch alignment {
            case .left:
                commands += "left"
            case .center:
                commands += "center"
            case .right:
                commands += "right"
            case .start:
                commands += "start"
            case .end:
                commands += "end"
            }
            commands += "||"
        }

        if let baseline = baseline {
            commands += "textBaseline|"
            switch baseline {
            case .top:
                commands += "top"
            case .hanging:
                commands += "hanging"
            case .middle:
                commands += "middle"
            case .alphabetic:
                commands += "alphabetic"
            case .ideographic:
                commands += "ideographic"
            case .bottom:
                commands += "bottom"
            }
            commands += "||"
        }

        commands += "textMetric|\(id)|\(text)"

        return commands
    }

    internal override func setupCommand() -> String {
        let commands = "createTextMetric|\(id.uuidString)"
        return commands
    }


}
