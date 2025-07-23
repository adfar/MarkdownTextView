import SwiftUI
import MarkdownTextView

struct MarkdownTextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> MarkdownTextView {
        let markdownView = MarkdownTextView()
        markdownView.delegate = context.coordinator
        return markdownView
    }
    
    func updateUIView(_ uiView: MarkdownTextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    class Coordinator: NSObject, MarkdownTextViewDelegate {
        let parent: MarkdownTextViewWrapper
        
        init(_ parent: MarkdownTextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: MarkdownTextView) {
            parent.text = textView.text
        }
        
        func textViewDidChangeSelection(_ textView: MarkdownTextView) {
            // Handle selection changes if needed
        }
    }
}

struct ContentView: View {
    @State private var markdownText = """
# MarkdownTextView Demo

Welcome to the **MarkdownTextView** example app! This demonstrates live markdown formatting.

## Supported Syntax

### Text Formatting
- **Bold text** using double asterisks
- __Bold text__ using double underscores  
- *Italic text* using single asterisks
- _Italic text_ using single underscores
- ~~Strikethrough text~~ using double tildes
- `Inline code` using backticks

### Headers
# Header 1
## Header 2  
### Header 3
#### Header 4
##### Header 5
###### Header 6

### Mixed Examples
You can combine **bold** and *italic* text together.

Here's some `code` in a sentence with **bold** text.

## Try Editing!
Start typing to see live markdown formatting in action. The syntax highlighting updates as you type, just like in Bear!

### Performance Test
Type rapidly to test the <10ms parsing requirement. The formatter should keep up with your typing speed without lag.
"""
    
    @State private var selectedDemo = "Interactive"
    private let demoOptions = ["Interactive", "Syntax Showcase", "Performance Test"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Demo selector
                Picker("Demo Type", selection: $selectedDemo) {
                    ForEach(demoOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Markdown editor
                MarkdownTextViewWrapper(text: $markdownText)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .padding()
                
                // Demo controls
                VStack(alignment: .leading, spacing: 8) {
                    Text("Demo Controls")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Clear") {
                            markdownText = ""
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Load Demo") {
                            loadDemoContent()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Syntax Test") {
                            loadSyntaxTest()
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Character count
                    Text("Characters: \(markdownText.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("MarkdownTextView")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                NavigationLink(destination: AdvancedTestViewWrapper()) {
                    Image(systemName: "gear")
                }
            )
        }
        .onAppear {
            loadDemoContent()
        }
        .onChange(of: selectedDemo) { _ in
            loadDemoContent()
        }
    }
    
    private func loadDemoContent() {
        switch selectedDemo {
        case "Interactive":
            markdownText = """
# Interactive Demo

Start typing here to test live markdown formatting!

Try these examples:
- Type **bold** for bold text
- Type *italic* for italic text  
- Type `code` for inline code
- Type ~~strike~~ for strikethrough
- Type # Header for headers

## Your Content Below:


"""
            
        case "Syntax Showcase":
            markdownText = """
# Complete Syntax Showcase

## Bold Text Examples
**Double asterisks make bold text**
__Double underscores also make bold text__

## Italic Text Examples  
*Single asterisks make italic text*
_Single underscores also make italic text_

## Code Examples
Here's some `inline code` in a sentence.
The `var` keyword defines a variable.

## Strikethrough Examples
~~This text is crossed out~~
Use ~~strikethrough~~ for deleted content.

## Header Examples
# Largest Header (H1)
## Second Largest (H2)
### Third Level (H3)
#### Fourth Level (H4)
##### Fifth Level (H5)
###### Smallest Header (H6)

## Mixed Formatting
You can **combine** *different* `formatting` ~~types~~ together!

**Bold with *italic inside* works great.**

## Performance Test Content
Lorem ipsum dolor sit amet, consectetur adipiscing elit. **Sed do eiusmod** tempor incididunt ut labore et dolore magna aliqua. *Ut enim ad minim* veniam, quis nostrud exercitation ullamco laboris nisi ut `aliquip ex ea` commodo consequat.

~~Duis aute irure~~ dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. **Excepteur sint occaecat** cupidatat non proident, sunt in culpa qui *officia deserunt* mollit anim id est laborum.
"""
            
        case "Performance Test":
            markdownText = generatePerformanceTestContent()
            
        default:
            break
        }
    }
    
    private func loadSyntaxTest() {
        markdownText = """
# Syntax Test Suite

## Basic Formatting
**bold** *italic* `code` ~~strike~~

## Nested Cases
**bold with *italic* inside**
*italic with **bold** inside*

## Edge Cases
** not bold ** (spaces)
*not italic * (trailing space)
`unclosed code
~~unclosed strike

## Mixed Line
This line has **bold**, *italic*, `code`, and ~~strike~~ all together.

## Headers Test
# H1
## H2
### H3
#### H4
##### H5
###### H6

### Invalid headers
####### Too many hashes
#No space after hash

## Rapid Testing
Type quickly here to test parsing performance:

"""
    }
    
    private func generatePerformanceTestContent() -> String {
        let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
        let boldText = "**Sed do eiusmod tempor incididunt** ut labore et dolore magna aliqua. "
        let italicText = "*Ut enim ad minim veniam* quis nostrud exercitation ullamco. "
        let codeText = "`laboris nisi ut aliquip` ex ea commodo consequat. "
        let strikeText = "~~Duis aute irure dolor~~ in reprehenderit in voluptate. "
        
        var content = "# Performance Test (3000+ words)\n\n"
        
        // Generate approximately 3000 words with mixed formatting
        for i in 1...50 {
            content += "## Section \(i)\n\n"
            content += loremIpsum + boldText + italicText + codeText + strikeText
            content += loremIpsum + boldText + italicText + "\n\n"
        }
        
        content += "## End Performance Test\n\nType rapidly in this section to test real-time parsing performance!"
        
        return content
    }
}

struct AdvancedTestViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AdvancedTestViewController {
        return AdvancedTestViewController()
    }
    
    func updateUIViewController(_ uiViewController: AdvancedTestViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ContentView()
}