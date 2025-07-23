import Foundation

// MARK: - List Formatter (Example of Extensibility)

public struct ListFormatter: BlockFormatter {
    public let priority: Int = 250 // Higher than other block formatters
    
    public init() {}
    
    public func canParseLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Unordered list patterns: -, *, +
        if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
            return true
        }
        
        // Ordered list pattern: 1. 2. etc.
        let orderedPattern = "^\\d+\\. "
        if let regex = try? NSRegularExpression(pattern: orderedPattern),
           regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.count)) != nil {
            return true
        }
        
        return false
    }
    
    public func parseBlock(lines: [String], startIndex: String.Index, in text: String) -> (node: SyntaxNode?, consumedLines: Int)? {
        var consumedLines = 0
        var listItems: [SyntaxNode] = []
        var currentIndex = startIndex
        
        // Parse consecutive list items
        for line in lines {
            guard canParseLine(line) else { break }
            
            let lineEndIndex = text.index(currentIndex, offsetBy: line.count)
            
            if let listItem = parseListItem(line: line, startIndex: currentIndex, endIndex: lineEndIndex, in: text) {
                listItems.append(listItem)
                consumedLines += 1
                currentIndex = text.index(after: lineEndIndex) // Move past newline
            } else {
                break
            }
        }
        
        guard !listItems.isEmpty else { return nil }
        
        // Determine list type from first item
        let firstLine = lines[0].trimmingCharacters(in: .whitespaces)
        let containerType: ContainerType
        
        if firstLine.hasPrefix("- ") {
            containerType = .unorderedList(marker: "-")
        } else if firstLine.hasPrefix("* ") {
            containerType = .unorderedList(marker: "*")
        } else if firstLine.hasPrefix("+ ") {
            containerType = .unorderedList(marker: "+")
        } else {
            // Ordered list
            containerType = .orderedList(startNumber: 1)
        }
        
        let listEndIndex = listItems.last?.range.upperBound ?? startIndex
        
        let containerNode = ContainerNode(
            type: containerType,
            fullRange: startIndex..<listEndIndex,
            children: listItems,
            metadata: ["itemCount": listItems.count]
        )
        
        return (node: .container(containerNode), consumedLines: consumedLines)
    }
    
    private func parseListItem(line: String, startIndex: String.Index, endIndex: String.Index, in text: String) -> SyntaxNode? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Calculate indentation level
        let leadingWhitespace = line.prefix { $0.isWhitespace }
        let level = leadingWhitespace.count / 2 // Assume 2 spaces per level
        
        var marker = ""
        var contentStart = ""
        
        if trimmed.hasPrefix("- ") {
            marker = "-"
            contentStart = String(trimmed.dropFirst(2))
        } else if trimmed.hasPrefix("* ") {
            marker = "*"
            contentStart = String(trimmed.dropFirst(2))
        } else if trimmed.hasPrefix("+ ") {
            marker = "+"
            contentStart = String(trimmed.dropFirst(2))
        } else if let regex = try? NSRegularExpression(pattern: "^(\\d+)\\. (.*)$"),
                  let match = regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.count)) {
            let numberRange = match.range(at: 1)
            let contentRange = match.range(at: 2)
            marker = String(trimmed[Range(numberRange, in: trimmed)!]) + "."
            contentStart = String(trimmed[Range(contentRange, in: trimmed)!])
        } else {
            return nil
        }
        
        // Find content range in original text
        let markerWithSpace = marker == "-" || marker == "*" || marker == "+" ? marker + " " : marker + " "
        let markerStartInLine = line.range(of: markerWithSpace)?.lowerBound ?? line.startIndex
        let contentStartInLine = line.range(of: contentStart)?.lowerBound ?? line.endIndex
        
        let markerStartIndex = text.index(startIndex, offsetBy: line.distance(from: line.startIndex, to: markerStartInLine))
        let markerEndIndex = text.index(markerStartIndex, offsetBy: markerWithSpace.count)
        let contentStartIndex = text.index(startIndex, offsetBy: line.distance(from: line.startIndex, to: contentStartInLine))
        
        let containerNode = ContainerNode(
            type: .listItem(level: level, marker: marker),
            fullRange: startIndex..<endIndex,
            children: [.text(range: contentStartIndex..<endIndex)],
            metadata: ["marker": marker, "level": level]
        )
        
        return .container(containerNode)
    }
}