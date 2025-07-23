import Foundation

// MARK: - Bold Formatter

public struct BoldFormatter: InlineFormatter {
    public let formattingType: FormattingType = .bold
    public let pattern: String = "\\*\\*([^*]+?)\\*\\*|__([^_]+?)__"
    public let priority: Int = 150 // Higher than italic to avoid conflicts
    
    public init() {}
}

// MARK: - Italic Formatter

public struct ItalicFormatter: InlineFormatter {
    public let formattingType: FormattingType = .italic
    public let pattern: String = "\\*([^*]+?)\\*|_([^_]+?)_"
    public let priority: Int = 100
    
    public init() {}
}

// MARK: - Strikethrough Formatter

public struct StrikethroughFormatter: InlineFormatter {
    public let formattingType: FormattingType = .strikethrough
    public let pattern: String = "~~([^~]+?)~~"
    public let priority: Int = 130
    
    public init() {}
}

// MARK: - Inline Code Formatter

public struct InlineCodeFormatter: InlineFormatter {
    public let formattingType: FormattingType = .inlineCode
    public let pattern: String = "`([^`]+?)`"
    public let priority: Int = 140 // Higher priority to avoid conflicts with other formatting
    
    public init() {}
}

// MARK: - Header Formatter

public struct HeaderFormatter: BlockFormatter {
    public let priority: Int = 200
    
    public init() {}
    
    public func canParseLine(_ line: String) -> Bool {
        return line.hasPrefix("#") && line.contains(" ")
    }
    
    public func parseBlock(lines: [String], startIndex: String.Index, in text: String) -> (node: SyntaxNode?, consumedLines: Int)? {
        guard let line = lines.first, canParseLine(line) else { return nil }
        
        let headerRegex = try! NSRegularExpression(pattern: "^(#{1,6})\\s+(.+)$")
        let range = NSRange(location: 0, length: line.count)
        
        guard let match = headerRegex.firstMatch(in: line, options: [], range: range) else {
            return nil
        }
        
        let hashRange = match.range(at: 1)
        let contentRange = match.range(at: 2)
        
        let headerLevel = hashRange.length
        let formattingType: FormattingType
        
        switch headerLevel {
        case 1: formattingType = .header1
        case 2: formattingType = .header2
        case 3: formattingType = .header3
        case 4: formattingType = .header4
        case 5: formattingType = .header5
        case 6: formattingType = .header6
        default: return nil
        }
        
        // Calculate ranges in the full text
        let lineEndIndex = text.index(startIndex, offsetBy: line.count)
        
        let hashStartIndex = text.index(startIndex, offsetBy: hashRange.location)
        let hashEndIndex = text.index(startIndex, offsetBy: hashRange.location + hashRange.length)
        let contentStartIndex = text.index(startIndex, offsetBy: contentRange.location)
        let contentEndIndex = text.index(startIndex, offsetBy: contentRange.location + contentRange.length)
        
        let formattedNode = FormattedNode(
            type: formattingType,
            fullRange: startIndex..<lineEndIndex,
            contentRange: contentStartIndex..<contentEndIndex,
            markerRanges: [hashStartIndex..<hashEndIndex]
        )
        
        return (node: .formatted(formattedNode), consumedLines: 1)
    }
}