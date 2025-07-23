import Foundation

public enum FormattingType: CaseIterable {
    case bold
    case italic
    case header1
    case header2
    case header3
    case header4
    case header5
    case header6
    case inlineCode
    case strikethrough
}

public enum SyntaxNode {
    case text(range: Range<String.Index>)
    case formatted(
        type: FormattingType,
        fullRange: Range<String.Index>,
        contentRange: Range<String.Index>,
        markerRanges: [Range<String.Index>]
    )
}

public struct SyntaxTree {
    public let nodes: [SyntaxNode]
    public let sourceString: String
    
    public init(nodes: [SyntaxNode], sourceString: String) {
        self.nodes = nodes
        self.sourceString = sourceString
    }
}

extension SyntaxNode {
    public var range: Range<String.Index> {
        switch self {
        case .text(let range):
            return range
        case .formatted(_, let fullRange, _, _):
            return fullRange
        }
    }
    
    public var isFormatted: Bool {
        switch self {
        case .text:
            return false
        case .formatted:
            return true
        }
    }
}

extension FormattingType {
    public var headerLevel: Int? {
        switch self {
        case .header1: return 1
        case .header2: return 2
        case .header3: return 3
        case .header4: return 4
        case .header5: return 5
        case .header6: return 6
        default: return nil
        }
    }
    
    public var isHeader: Bool {
        return headerLevel != nil
    }
}