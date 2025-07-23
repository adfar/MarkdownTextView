import Foundation

public protocol MarkdownFormatter {
    /// The priority of this formatter (higher values parsed first)
    var priority: Int { get }
    
    /// Check if this formatter can parse the given text at the specified range
    func canParse(_ text: String, at range: Range<String.Index>) -> Bool
    
    /// Parse the text and return a syntax node if successful
    func parse(_ text: String, at range: Range<String.Index>) -> SyntaxNode?
    
    /// Get all matches for this formatter in the given text
    func findMatches(in text: String, range: Range<String.Index>) -> [SyntaxNode]
}

public protocol InlineFormatter: MarkdownFormatter {
    /// The formatting type this formatter handles
    var formattingType: FormattingType { get }
    
    /// The regex pattern for matching this format
    var pattern: String { get }
}

public protocol BlockFormatter: MarkdownFormatter {
    /// Check if this formatter can parse the given line
    func canParseLine(_ line: String) -> Bool
    
    /// Parse multiple lines for block-level constructs
    func parseBlock(lines: [String], startIndex: String.Index, in text: String) -> (node: SyntaxNode?, consumedLines: Int)?
}

// MARK: - Default Implementations

extension InlineFormatter {
    public var priority: Int { 100 } // Default priority for inline formatters
    
    public func canParse(_ text: String, at range: Range<String.Index>) -> Bool {
        let substring = String(text[range])
        let regex = try? NSRegularExpression(pattern: pattern)
        return regex?.firstMatch(in: substring, range: NSRange(location: 0, length: substring.count)) != nil
    }
    
    public func parse(_ text: String, at range: Range<String.Index>) -> SyntaxNode? {
        let matches = findMatches(in: text, range: range)
        return matches.first
    }
    
    public func findMatches(in text: String, range: Range<String.Index>) -> [SyntaxNode] {
        let substring = String(text[range])
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let nsRange = NSRange(location: 0, length: substring.count)
        let matches = regex.matches(in: substring, range: nsRange)
        
        var nodes: [SyntaxNode] = []
        
        for match in matches {
            let contentGroup = match.range(at: 1).location != NSNotFound ? 1 : 2
            let contentRange = match.range(at: contentGroup)
            
            guard let fullRange = Range(match.range, in: substring),
                  let contentNSRange = Range(contentRange, in: substring) else { continue }
            
            let fullStringRange = Range(uncheckedBounds: (
                lower: text.index(range.lowerBound, offsetBy: fullRange.lowerBound.utf16Offset(in: substring)),
                upper: text.index(range.lowerBound, offsetBy: fullRange.upperBound.utf16Offset(in: substring))
            ))
            
            let contentStringRange = Range(uncheckedBounds: (
                lower: text.index(range.lowerBound, offsetBy: contentNSRange.lowerBound.utf16Offset(in: substring)),
                upper: text.index(range.lowerBound, offsetBy: contentNSRange.upperBound.utf16Offset(in: substring))
            ))
            
            let markerRanges = calculateMarkerRanges(fullRange: fullStringRange, contentRange: contentStringRange)
            
            let formattedNode = FormattedNode(
                type: formattingType,
                fullRange: fullStringRange,
                contentRange: contentStringRange,
                markerRanges: markerRanges
            )
            
            nodes.append(.formatted(formattedNode))
        }
        
        return nodes
    }
    
    private func calculateMarkerRanges(fullRange: Range<String.Index>, contentRange: Range<String.Index>) -> [Range<String.Index>] {
        return [
            fullRange.lowerBound..<contentRange.lowerBound,
            contentRange.upperBound..<fullRange.upperBound
        ]
    }
}

extension BlockFormatter {
    public var priority: Int { 200 } // Higher priority for block formatters
    
    public func canParse(_ text: String, at range: Range<String.Index>) -> Bool {
        let line = String(text[range])
        return canParseLine(line)
    }
    
    public func parse(_ text: String, at range: Range<String.Index>) -> SyntaxNode? {
        let line = String(text[range])
        return parseBlock(lines: [line], startIndex: range.lowerBound, in: text)?.node
    }
    
    public func findMatches(in text: String, range: Range<String.Index>) -> [SyntaxNode] {
        // Block formatters typically work on full lines/documents
        // This default implementation can be overridden for specific needs
        if let node = parse(text, at: range) {
            return [node]
        }
        return []
    }
}