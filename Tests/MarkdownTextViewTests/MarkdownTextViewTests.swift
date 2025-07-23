import Testing
@testable import MarkdownTextView

@Test func testParserBasicText() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("Hello world")
    
    #expect(result.nodes.count == 1)
    if case .text(let range) = result.nodes[0] {
        #expect(String(result.sourceString[range]) == "Hello world")
    } else {
        #expect(false, "Expected text node")
    }
}

@Test func testParserBoldText() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("**bold**")
    
    #expect(result.nodes.count == 1)
    if case .formatted(let type, _, let contentRange, _) = result.nodes[0] {
        #expect(type == .bold)
        #expect(String(result.sourceString[contentRange]) == "bold")
    } else {
        #expect(false, "Expected formatted node")
    }
}

@Test func testParserItalicText() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("*italic*")
    
    #expect(result.nodes.count == 1)
    if case .formatted(let type, _, let contentRange, _) = result.nodes[0] {
        #expect(type == .italic)
        #expect(String(result.sourceString[contentRange]) == "italic")
    } else {
        #expect(false, "Expected formatted node")
    }
}

@Test func testParserHeader() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("# Header 1")
    
    #expect(result.nodes.count == 1)
    if case .formatted(let type, _, let contentRange, _) = result.nodes[0] {
        #expect(type == .header1)
        #expect(String(result.sourceString[contentRange]) == "Header 1")
    } else {
        #expect(false, "Expected formatted node")
    }
}

@Test func testParserInlineCode() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("`code`")
    
    #expect(result.nodes.count == 1)
    if case .formatted(let type, _, let contentRange, _) = result.nodes[0] {
        #expect(type == .inlineCode)
        #expect(String(result.sourceString[contentRange]) == "code")
    } else {
        #expect(false, "Expected formatted node")
    }
}

@Test func testParserStrikethrough() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("~~strike~~")
    
    #expect(result.nodes.count == 1)
    if case .formatted(let type, _, let contentRange, _) = result.nodes[0] {
        #expect(type == .strikethrough)
        #expect(String(result.sourceString[contentRange]) == "strike")
    } else {
        #expect(false, "Expected formatted node")
    }
}

@Test func testParserMixedContent() async throws {
    let parser = MarkdownParser()
    let result = parser.parse("Hello **bold** and *italic* text")
    
    #expect(result.nodes.count == 5)
    
    // Check the structure
    if case .text(let range) = result.nodes[0] {
        #expect(String(result.sourceString[range]) == "Hello ")
    } else {
        #expect(false, "Expected text node at index 0")
    }
    
    if case .formatted(let type, _, let contentRange, _) = result.nodes[1] {
        #expect(type == .bold)
        #expect(String(result.sourceString[contentRange]) == "bold")
    } else {
        #expect(false, "Expected bold node at index 1")
    }
    
    if case .text(let range) = result.nodes[2] {
        #expect(String(result.sourceString[range]) == " and ")
    } else {
        #expect(false, "Expected text node at index 2")
    }
    
    if case .formatted(let type, _, let contentRange, _) = result.nodes[3] {
        #expect(type == .italic)
        #expect(String(result.sourceString[contentRange]) == "italic")
    } else {
        #expect(false, "Expected italic node at index 3")
    }
    
    if case .text(let range) = result.nodes[4] {
        #expect(String(result.sourceString[range]) == " text")
    } else {
        #expect(false, "Expected text node at index 4")
    }
}

@Test func testSyntaxTreeStructure() async throws {
    let nodes: [SyntaxNode] = [
        .text(range: "test".startIndex..<"test".endIndex),
        .formatted(type: .bold, fullRange: "test".startIndex..<"test".endIndex, contentRange: "test".startIndex..<"test".endIndex, markerRanges: [])
    ]
    let tree = SyntaxTree(nodes: nodes, sourceString: "test")
    
    #expect(tree.nodes.count == 2)
    #expect(tree.sourceString == "test")
}
