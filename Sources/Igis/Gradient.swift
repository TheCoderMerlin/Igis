import Foundation

public class Gradient : CanvasIdentifiedObject {

    public enum Mode {
        case linear(start:Point, end:Point)
        case radial(center1:Point, radius1:Double, center2:Point, radius2:Double)
    }
    
    public let mode : Mode
    public private(set) var colorStops : [ColorStop]

    public init(mode:Mode) {
        self.mode = mode
        self.colorStops = [ColorStop]()
    }

    public func addColorStop(_ colorStop:ColorStop) {
        colorStops.append(colorStop)
    }

    internal override func canvasCommand() -> String {
        print("ERROR: canvasCommand requested on gradient which may not be directly rendered. ID: \(id.uuidString).")
        return ""
    }

    internal override func setupCommand() -> String {
        var commands = ""
        switch mode {
        case .linear(let start, let end):
            commands += "createLinearGradient|\(id.uuidString)|\(start.x)|\(start.y)|\(end.x)|\(end.y)|\(colorStops.count)|"
        case .radial(let center1, let radius1, let center2, let radius2):
            commands += "createRadialGradient|\(id.uuidString)|\(center1.x)|\(center1.y)|\(radius1)|\(center2.x)|\(center2.y)|\(radius2)|\(colorStops.count)|"            
        }
        commands += colorStops.map {"\($0.position)|\($0.color.style)"}.joined(separator:"|")
        
        return commands
    }
}
