import Foundation

public struct MarkdownParser {
    
    public init() {}
    
    public func parse(_ text: String) -> SyntaxTree {
        let lines = text.components(separatedBy: .newlines)
        var nodes: [SyntaxNode] = []
        var currentIndex = text.startIndex
        
        for (lineIndex, line) in lines.enumerated() {
            let lineStartIndex = currentIndex
            let lineEndIndex = text.index(currentIndex, offsetBy: line.count)
            
            if line.hasPrefix("#") {
                if let headerNode = parseHeader(line: line, startIndex: lineStartIndex, endIndex: lineEndIndex, in: text) {
                    nodes.append(headerNode)
                } else {
                    nodes.append(.text(range: lineStartIndex..<lineEndIndex))
                }
            } else {
                let lineNodes = parseInlineFormatting(line: line, startIndex: lineStartIndex, endIndex: lineEndIndex, in: text)
                nodes.append(contentsOf: lineNodes)
            }
            
            // Add newline character if not the last line
            if lineIndex < lines.count - 1 {
                let newlineStart = lineEndIndex
                let newlineEnd = text.index(after: lineEndIndex)
                if newlineEnd <= text.endIndex {
                    nodes.append(.text(range: newlineStart..<newlineEnd))
                    currentIndex = newlineEnd
                } else {
                    currentIndex = lineEndIndex
                }
            } else {
                currentIndex = lineEndIndex
            }
        }
        
        return SyntaxTree(nodes: nodes, sourceString: text)
    }
    
    private func parseHeader(line: String, startIndex: String.Index, endIndex: String.Index, in text: String) -> SyntaxNode? {
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
        
        let hashStartIndex = text.index(startIndex, offsetBy: hashRange.location)
        let hashEndIndex = text.index(startIndex, offsetBy: hashRange.location + hashRange.length)
        let contentStartIndex = text.index(startIndex, offsetBy: contentRange.location)
        let contentEndIndex = text.index(startIndex, offsetBy: contentRange.location + contentRange.length)
        
        return .formatted(
            type: formattingType,
            fullRange: startIndex..<endIndex,
            contentRange: contentStartIndex..<contentEndIndex,
            markerRanges: [hashStartIndex..<hashEndIndex]
        )
    }
    
    private func parseInlineFormatting(line: String, startIndex: String.Index, endIndex: String.Index, in text: String) -> [SyntaxNode] {
        var nodes: [SyntaxNode] = []
        var currentPosition = 0
        
        let patterns: [(FormattingType, String)] = [
            (.bold, "\\*\\*([^*]+?)\\*\\*|__([^_]+?)__"),
            (.strikethrough, "~~([^~]+?)~~"),
            (.inlineCode, "`([^`]+?)`"),
            (.italic, "\\*([^*]+?)\\*|_([^_]+?)_")
        ]
        
        var matches: [(type: FormattingType, range: NSRange, contentRange: NSRange)] = []
        
        for (type, pattern) in patterns {
            let regex = try! NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(location: 0, length: line.count)
            
            for match in regex.matches(in: line, options: [], range: nsRange) {
                let contentGroup = match.range(at: 1).location != NSNotFound ? 1 : 2
                let contentRange = match.range(at: contentGroup)
                
                matches.append((type: type, range: match.range, contentRange: contentRange))
            }
        }
        
        matches.sort { 
            if $0.range.location == $1.range.location {
                return $0.range.length > $1.range.length // Prefer longer matches
            }
            return $0.range.location < $1.range.location 
        }
        
        for match in matches {
            // Skip overlapping matches
            if match.range.location < currentPosition {
                continue
            }
            
            if match.range.location > currentPosition {
                let textStartIndex = text.index(startIndex, offsetBy: currentPosition)
                let textEndIndex = text.index(startIndex, offsetBy: match.range.location)
                nodes.append(.text(range: textStartIndex..<textEndIndex))
            }
            
            let fullStartIndex = text.index(startIndex, offsetBy: match.range.location)
            let fullEndIndex = text.index(startIndex, offsetBy: match.range.location + match.range.length)
            let contentStartIndex = text.index(startIndex, offsetBy: match.contentRange.location)
            let contentEndIndex = text.index(startIndex, offsetBy: match.contentRange.location + match.contentRange.length)
            
            let markerRanges = calculateMarkerRanges(for: match.type, fullRange: fullStartIndex..<fullEndIndex, contentRange: contentStartIndex..<contentEndIndex)
            
            nodes.append(.formatted(
                type: match.type,
                fullRange: fullStartIndex..<fullEndIndex,
                contentRange: contentStartIndex..<contentEndIndex,
                markerRanges: markerRanges
            ))
            
            currentPosition = match.range.location + match.range.length
        }
        
        if currentPosition < line.count {
            let textStartIndex = text.index(startIndex, offsetBy: currentPosition)
            nodes.append(.text(range: textStartIndex..<endIndex))
        }
        
        if nodes.isEmpty {
            nodes.append(.text(range: startIndex..<endIndex))
        }
        
        return nodes
    }
    
    private func calculateMarkerRanges(for type: FormattingType, fullRange: Range<String.Index>, contentRange: Range<String.Index>) -> [Range<String.Index>] {
        switch type {
        case .bold:
            return [
                fullRange.lowerBound..<contentRange.lowerBound,
                contentRange.upperBound..<fullRange.upperBound
            ]
        case .italic:
            return [
                fullRange.lowerBound..<contentRange.lowerBound,
                contentRange.upperBound..<fullRange.upperBound
            ]
        case .inlineCode:
            return [
                fullRange.lowerBound..<contentRange.lowerBound,
                contentRange.upperBound..<fullRange.upperBound
            ]
        case .strikethrough:
            return [
                fullRange.lowerBound..<contentRange.lowerBound,
                contentRange.upperBound..<fullRange.upperBound
            ]
        default:
            return []
        }
    }
}