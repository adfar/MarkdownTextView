import UIKit

public class MarkdownTextStorage: NSTextStorage {
    
    private var backingStore = NSMutableAttributedString()
    private let parser = MarkdownParser()
    private var syntaxTree: SyntaxTree?
    
    public override var string: String {
        return backingStore.string
    }
    
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        backingStore.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        parseAndApplyFormatting()
    }
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    private func parseAndApplyFormatting() {
        let text = backingStore.string
        syntaxTree = parser.parse(text)
        
        guard let syntaxTree = syntaxTree else { return }
        
        // Reset all attributes to default
        let fullRange = NSRange(location: 0, length: text.count)
        backingStore.removeAttribute(.font, range: fullRange)
        backingStore.removeAttribute(.foregroundColor, range: fullRange)
        backingStore.removeAttribute(.backgroundColor, range: fullRange)
        
        // Apply default font
        let defaultFont = UIFont.systemFont(ofSize: 16)
        backingStore.addAttribute(.font, value: defaultFont, range: fullRange)
        backingStore.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
        
        // Apply formatting based on syntax tree
        applyFormattingToNodes(syntaxTree.nodes, in: text)
    }
    
    private func applyFormattingToNodes(_ nodes: [SyntaxNode], in text: String) {
        for node in nodes {
            switch node {
            case .text:
                // Already has default formatting
                break
            case .formatted(let formattedNode):
                applyFormatting(for: formattedNode.type, contentRange: formattedNode.contentRange, in: text)
            case .container(let containerNode):
                applyContainerFormatting(for: containerNode, in: text)
                // Recursively apply formatting to children
                applyFormattingToNodes(containerNode.children, in: text)
            }
        }
    }
    
    private func applyFormatting(for type: FormattingType, contentRange: Range<String.Index>, in text: String) {
        let nsRange = NSRange(contentRange, in: text)
        
        switch type {
        case .bold:
            let boldFont = UIFont.boldSystemFont(ofSize: 16)
            backingStore.addAttribute(.font, value: boldFont, range: nsRange)
            
        case .italic:
            let italicFont = UIFont.italicSystemFont(ofSize: 16)
            backingStore.addAttribute(.font, value: italicFont, range: nsRange)
            
        case .header1:
            let headerFont = UIFont.boldSystemFont(ofSize: 32)
            backingStore.addAttribute(.font, value: headerFont, range: nsRange)
            
        case .header2:
            let headerFont = UIFont.boldSystemFont(ofSize: 28)
            backingStore.addAttribute(.font, value: headerFont, range: nsRange)
            
        case .header3:
            let headerFont = UIFont.boldSystemFont(ofSize: 24)
            backingStore.addAttribute(.font, value: headerFont, range: nsRange)
            
        case .header4:
            let headerFont = UIFont.boldSystemFont(ofSize: 20)
            backingStore.addAttribute(.font, value: headerFont, range: nsRange)
            
        case .header5:
            let headerFont = UIFont.boldSystemFont(ofSize: 18)
            backingStore.addAttribute(.font, value: headerFont, range: nsRange)
            
        case .header6:
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            backingStore.addAttribute(.font, value: headerFont, range: nsRange)
            
        case .inlineCode:
            let codeFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            backingStore.addAttribute(.font, value: codeFont, range: nsRange)
            backingStore.addAttribute(.backgroundColor, value: UIColor.systemGray6, range: nsRange)
            
        case .strikethrough:
            backingStore.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }
    }
    
    private func applyContainerFormatting(for containerNode: ContainerNode, in text: String) {
        let nsRange = NSRange(containerNode.fullRange, in: text)
        
        switch containerNode.type {
        case .unorderedList(let marker):
            // Apply list formatting - could add indentation, bullet styling, etc.
            break
        case .orderedList(let startNumber):
            // Apply ordered list formatting
            break
        case .listItem(let level, let marker):
            // Apply list item formatting with proper indentation
            let indentationSpaces = level * 20 // 20 points per level
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = CGFloat(indentationSpaces)
            paragraphStyle.headIndent = CGFloat(indentationSpaces + 20) // Extra indent for text after bullet
            backingStore.addAttribute(.paragraphStyle, value: paragraphStyle, range: nsRange)
        case .blockquote:
            // Apply blockquote formatting - gray background, indentation, etc.
            backingStore.addAttribute(.backgroundColor, value: UIColor.systemGray6, range: nsRange)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 20
            paragraphStyle.headIndent = 20
            backingStore.addAttribute(.paragraphStyle, value: paragraphStyle, range: nsRange)
        }
    }
    
    public func getSyntaxTree() -> SyntaxTree? {
        return syntaxTree
    }
}