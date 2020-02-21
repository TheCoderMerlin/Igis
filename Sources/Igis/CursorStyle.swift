public class CursorStyle : CanvasObject {
    public enum Style {
        case crosshair
        case Eresize
        case help
        case move
        case Nresize
        case NEresize
        case NWresize
        case pointer
        case progress
        case Sresize
        case SEresize
        case SWresize
        case text
        case Wresize
        case wait
    }
    private let style : Style

    public init(style:Style) {
        self.style = style
    }

    internal override func canvasCommand() -> String {
        let commands = "cursorStyle|\(style)||"
        return commands
    }
}
