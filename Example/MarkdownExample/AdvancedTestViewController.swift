import UIKit
import MarkdownTextView

class AdvancedTestViewController: UIViewController {
    
    private let markdownTextView = MarkdownTextView()
    private let toolbar = UIToolbar()
    private let characterCountLabel = UILabel()
    private let parseTimeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTextView()
        loadInitialContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Advanced Testing"
        
        // Configure text view
        markdownTextView.backgroundColor = .systemBackground
        markdownTextView.layer.borderColor = UIColor.systemGray4.cgColor
        markdownTextView.layer.borderWidth = 1
        markdownTextView.layer.cornerRadius = 8
        
        // Configure toolbar
        toolbar.backgroundColor = .systemGray6
        
        // Configure labels
        characterCountLabel.font = .systemFont(ofSize: 12)
        characterCountLabel.textColor = .systemGray
        characterCountLabel.text = "Characters: 0"
        
        parseTimeLabel.font = .systemFont(ofSize: 12)
        parseTimeLabel.textColor = .systemGray
        parseTimeLabel.text = "Parse time: 0ms"
        
        // Add subviews
        view.addSubview(markdownTextView)
        view.addSubview(toolbar)
        view.addSubview(characterCountLabel)
        view.addSubview(parseTimeLabel)
        
        // Configure toolbar items
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearText))
        let stressTestButton = UIBarButtonItem(title: "Stress Test", style: .plain, target: self, action: #selector(runStressTest))
        let syntaxTestButton = UIBarButtonItem(title: "Syntax Test", style: .plain, target: self, action: #selector(loadSyntaxTest))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [clearButton, flexSpace, syntaxTestButton, flexSpace, stressTestButton]
    }
    
    private func setupConstraints() {
        markdownTextView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        parseTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Text view constraints
            markdownTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            markdownTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            markdownTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            markdownTextView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -8),
            
            // Toolbar constraints
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: characterCountLabel.topAnchor, constant: -8),
            
            // Labels constraints
            characterCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            characterCountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            parseTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            parseTimeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupTextView() {
        markdownTextView.delegate = self
    }
    
    private func loadInitialContent() {
        markdownTextView.text = """
# Advanced Testing Console

This view provides detailed testing capabilities for the MarkdownTextView.

## Performance Monitoring
- Character count is tracked in real-time
- Parse time is measured for each edit
- Stress testing available via toolbar

## Test Features
Use the toolbar buttons to:
- **Clear**: Remove all text
- **Syntax Test**: Load comprehensive syntax examples
- **Stress Test**: Load large document for performance testing

## Live Editing
Start typing below to see real-time performance metrics:

"""
        updateMetrics()
    }
    
    private func updateMetrics() {
        let characterCount = markdownTextView.text.count
        characterCountLabel.text = "Characters: \(characterCount)"
        
        // Measure parse time
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Trigger a parse by accessing the syntax tree
        if let textStorage = markdownTextView.value(forKey: "textStorage") as? MarkdownTextStorage {
            _ = textStorage.getSyntaxTree()
        }
        
        let parseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // Convert to ms
        parseTimeLabel.text = String(format: "Parse time: %.2fms", parseTime)
        
        // Highlight performance issues
        if parseTime > 10 {
            parseTimeLabel.textColor = .systemRed
        } else if parseTime > 5 {
            parseTimeLabel.textColor = .systemOrange
        } else {
            parseTimeLabel.textColor = .systemGreen
        }
    }
    
    @objc private func clearText() {
        markdownTextView.text = ""
        updateMetrics()
    }
    
    @objc private func loadSyntaxTest() {
        markdownTextView.text = """
# Complete Syntax Test Suite

## Basic Formatting Tests
**Bold double asterisk**
__Bold double underscore__
*Italic single asterisk*
_Italic single underscore_
`Inline code backticks`
~~Strikethrough double tilde~~

## Header Tests
# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6

## Edge Cases
**Unclosed bold
*Unclosed italic
`Unclosed code
~~Unclosed strike

** Spaced markers **
* Spaced markers *

## Mixed Formatting
**Bold with *nested italic* inside**
*Italic with **nested bold** inside*
This sentence has **bold**, *italic*, `code`, and ~~strike~~ all mixed together.

## Rapid Parsing Test
Type quickly in this section to test real-time parsing performance. The parse time should remain under 10ms even with rapid typing.

"""
        updateMetrics()
    }
    
    @objc private func runStressTest() {
        // Generate a large document for stress testing
        var stressContent = "# Stress Test Document\n\n"
        
        let paragraphTemplate = """
Lorem ipsum dolor sit amet, **consectetur adipiscing** elit. *Sed do eiusmod* tempor incididunt ut `labore et dolore` magna aliqua. ~~Ut enim ad minim~~ veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

"""
        
        // Generate approximately 3000 words
        for i in 1...100 {
            stressContent += "## Section \(i)\n\n"
            stressContent += paragraphTemplate
            
            if i % 10 == 0 {
                stressContent += "### Subsection with `code` and **formatting**\n\n"
                stressContent += "Here's a subsection with *various* formatting **types** to test ~~parsing~~ performance.\n\n"
            }
        }
        
        stressContent += "## End of Stress Test\n\nDocument generated with ~3000 words and mixed formatting for performance testing."
        
        markdownTextView.text = stressContent
        updateMetrics()
        
        // Show alert with document stats
        let wordCount = stressContent.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let alert = UIAlertController(title: "Stress Test Loaded", 
                                    message: "Document: ~\(wordCount) words, \(stressContent.count) characters", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MarkdownTextViewDelegate

@MainActor
extension AdvancedTestViewController: MarkdownTextViewDelegate {
    func textViewDidChange(_ textView: MarkdownTextView) {
        updateMetrics()
    }
    
    func textViewDidChangeSelection(_ textView: MarkdownTextView) {
        // Could add selection-based metrics here
    }
}