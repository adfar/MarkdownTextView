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

public enum ContainerType {
    case unorderedList(marker: String)
    case orderedList(startNumber: Int)
    case listItem(level: Int, marker: String)
    case blockquote
}

public struct FormattedNode {
    public let type: FormattingType
    public let fullRange: Range<String.Index>
    public let contentRange: Range<String.Index>
    public let markerRanges: [Range<String.Index>]
    
    public init(type: FormattingType, fullRange: Range<String.Index>, contentRange: Range<String.Index>, markerRanges: [Range<String.Index>]) {
        self.type = type
        self.fullRange = fullRange
        self.contentRange = contentRange
        self.markerRanges = markerRanges
    }
}

public struct ContainerNode {
    public let type: ContainerType
    public let fullRange: Range<String.Index>
    public let children: [SyntaxNode]
    public let metadata: [String: Any]
    
    public init(type: ContainerType, fullRange: Range<String.Index>, children: [SyntaxNode], metadata: [String: Any] = [:]) {
        self.type = type
        self.fullRange = fullRange
        self.children = children
        self.metadata = metadata
    }
}

public enum SyntaxNode {
    case text(range: Range<String.Index>)
    case formatted(FormattedNode)
    case container(ContainerNode)
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
        case .formatted(let node):
            return node.fullRange
        case .container(let node):
            return node.fullRange
        }
    }
    
    public var isFormatted: Bool {
        switch self {
        case .text:
            return false
        case .formatted:
            return true
        case .container:
            return false
        }
    }
    
    public var isContainer: Bool {
        switch self {
        case .text, .formatted:
            return false
        case .container:
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