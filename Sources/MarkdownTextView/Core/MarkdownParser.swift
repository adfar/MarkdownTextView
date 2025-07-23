import Foundation

public struct MarkdownParser {
    
    private let blockFormatters: [BlockFormatter]
    private let inlineFormatters: [InlineFormatter]
    
    public init() {
        // Default formatters - easily extensible by adding new formatters here
        self.blockFormatters = [
            HeaderFormatter(),
            ListFormatter() // Example of extensibility - lists support
        ].sorted { $0.priority > $1.priority }
        
        self.inlineFormatters = [
            BoldFormatter(),
            StrikethroughFormatter(),
            InlineCodeFormatter(),
            ItalicFormatter()
        ].sorted { $0.priority > $1.priority }
    }
    
    public init(blockFormatters: [BlockFormatter] = [], inlineFormatters: [InlineFormatter] = []) {
        self.blockFormatters = blockFormatters.sorted { $0.priority > $1.priority }
        self.inlineFormatters = inlineFormatters.sorted { $0.priority > $1.priority }
    }
    
    public func parse(_ text: String) -> SyntaxTree {
        // Multi-pass parsing: Block-level first, then inline
        let blockNodes = parseBlockLevel(text)
        let finalNodes = parseInlineLevel(blockNodes, in: text)
        
        return SyntaxTree(nodes: finalNodes, sourceString: text)
    }
    
    private func parseBlockLevel(_ text: String) -> [SyntaxNode] {
        let lines = text.components(separatedBy: .newlines)
        var nodes: [SyntaxNode] = []
        var currentIndex = text.startIndex
        var lineIndex = 0
        
        while lineIndex < lines.count {
            let line = lines[lineIndex]
            let lineStartIndex = currentIndex
            let lineEndIndex = text.index(currentIndex, offsetBy: line.count)
            
            var blockParsed = false
            
            // Try block formatters
            for formatter in blockFormatters {
                if formatter.canParseLine(line) {
                    let remainingLines = Array(lines[lineIndex...])
                    if let result = formatter.parseBlock(lines: remainingLines, startIndex: lineStartIndex, in: text) {
                        nodes.append(result.node)
                        lineIndex += result.consumedLines
                        
                        // Update currentIndex to after consumed lines
                        for _ in 0..<result.consumedLines {
                            if lineIndex - 1 < lines.count {
                                currentIndex = text.index(currentIndex, offsetBy: lines[lineIndex - 1].count)
                                if lineIndex < lines.count {
                                    currentIndex = text.index(after: currentIndex) // Skip newline
                                }
                            }
                        }
                        
                        blockParsed = true
                        break
                    }
                }
            }
            
            if !blockParsed {
                // No block formatter matched, treat as regular text line
                nodes.append(.text(range: lineStartIndex..<lineEndIndex))
                lineIndex += 1
                
                // Add newline if not the last line
                if lineIndex < lines.count {
                    let newlineStart = lineEndIndex
                    let newlineEnd = text.index(after: lineEndIndex)
                    if newlineEnd <= text.endIndex {
                        nodes.append(.text(range: newlineStart..<newlineEnd))
                        currentIndex = newlineEnd
                    }
                } else {
                    currentIndex = lineEndIndex
                }
            }
        }
        
        return nodes
    }
    
    private func parseInlineLevel(_ nodes: [SyntaxNode], in text: String) -> [SyntaxNode] {
        var result: [SyntaxNode] = []
        
        for node in nodes {
            switch node {
            case .text(let range):
                let inlineNodes = parseInlineFormatting(in: text, range: range)
                result.append(contentsOf: inlineNodes)
            case .formatted(let formattedNode):
                // Parse inline formatting within the content of formatted nodes
                let contentNodes = parseInlineFormatting(in: text, range: formattedNode.contentRange)
                let updatedNode = FormattedNode(
                    type: formattedNode.type,
                    fullRange: formattedNode.fullRange,
                    contentRange: formattedNode.contentRange,
                    markerRanges: formattedNode.markerRanges
                )
                result.append(.formatted(updatedNode))
            case .container(let containerNode):
                // Recursively parse children
                let parsedChildren = parseInlineLevel(containerNode.children, in: text)
                let updatedContainer = ContainerNode(
                    type: containerNode.type,
                    fullRange: containerNode.fullRange,
                    children: parsedChildren,
                    metadata: containerNode.metadata
                )
                result.append(.container(updatedContainer))
            }
        }
        
        return result
    }
    
    private func parseInlineFormatting(in text: String, range: Range<String.Index>) -> [SyntaxNode] {
        var matches: [SyntaxNode] = []
        
        // Collect all matches from inline formatters
        for formatter in inlineFormatters {
            let formatterMatches = formatter.findMatches(in: text, range: range)
            matches.append(contentsOf: formatterMatches)
        }
        
        // Sort matches by position, preferring longer matches at same position
        matches.sort { match1, match2 in
            if match1.range.lowerBound == match2.range.lowerBound {
                return match1.range.count > match2.range.count
            }
            return match1.range.lowerBound < match2.range.lowerBound
        }
        
        // Remove overlapping matches and build final node list
        var nodes: [SyntaxNode] = []
        var currentPosition = range.lowerBound
        
        for match in matches {
            // Skip overlapping matches
            if match.range.lowerBound < currentPosition {
                continue
            }
            
            // Add text before this match
            if match.range.lowerBound > currentPosition {
                nodes.append(.text(range: currentPosition..<match.range.lowerBound))
            }
            
            // Add the match
            nodes.append(match)
            currentPosition = match.range.upperBound
        }
        
        // Add remaining text
        if currentPosition < range.upperBound {
            nodes.append(.text(range: currentPosition..<range.upperBound))
        }
        
        // If no matches found, return the original text
        if nodes.isEmpty {
            nodes.append(.text(range: range))
        }
        
        return nodes
    }
}