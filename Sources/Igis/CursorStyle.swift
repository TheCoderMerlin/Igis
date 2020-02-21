public class CursorStyle : CanvasObject {
    public enum Style : String {
        case crosshair = "crosshair"
        case Eresize = "e-resize"
        case help = "help"
        case move = "move"
        case Nresize = "n-resize"
        case NEresize = "ne-resize"
        case NWresize = "nw-resize"
        case pointer = "pointer"
        case progress = "progress"
        case Sresize = "s-resize"
        case SEresize = "se-resize"
        case SWresize = "sw-resize"
        case text = "text"
        case Wresize = "w-resize"
        case wait = "wait"
    }
    private let style : Style

    public init(style:Style) {
        self.style = style
    }

    internal override func canvasCommand() -> String {
        let commands = "cursorStyle|\(style.rawValue)||"
        return commands
    }
}
