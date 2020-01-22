import Foundation

public class Pattern : CanvasIdentifiedObject {

    public enum Repetition {
        case repeated
        case repeatedX
        case repeatedY
        case notRepeated
    }

    public let image : Image
    public let repetition : Repetition

    public init(image:Image, repetition:Repetition = .repeated) {
        self.image = image
        self.repetition = repetition
    }

    internal override func canvasCommand() -> String {
        print("ERROR: canvasCommand requested on pattern which may not be directly rendered. ID: \(id.uuidString).")
        return ""
    }

    internal override func setupCommand() -> String {
        let repetitionString : String
        switch repetition {
        case .repeated:
            repetitionString = "repeated"
        case .repeatedX:
            repetitionString = "repeatedX"
        case .repeatedY:
            repetitionString = "repeatedY"
        case .notRepeated:
            repetitionString = "notRepeated"
        }
        let command = "createPattern|\(id.uuidString)|\(image.id.uuidString)|\(repetitionString)"
        return command
    }

    
}
