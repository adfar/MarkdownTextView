import UIKit

public protocol MarkdownTextViewDelegate: AnyObject {
    func textViewDidChange(_ textView: MarkdownTextView)
    func textViewDidChangeSelection(_ textView: MarkdownTextView)
}

public class MarkdownTextView: UIView {
    
    // MARK: - Public Properties
    
    public var text: String {
        get { textStorage.string }
        set { 
            textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length), with: newValue)
        }
    }
    
    public var attributedText: NSAttributedString {
        return textStorage
    }
    
    public weak var delegate: MarkdownTextViewDelegate?
    
    // MARK: - Private Properties
    
    private let textStorage = MarkdownTextStorage()
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer()
    private let textView: UITextView
    private let scrollView = UIScrollView()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        textView = UITextView(frame: .zero, textContainer: textContainer)
        super.init(frame: frame)
        setupTextKit()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        textView = UITextView(frame: .zero, textContainer: textContainer)
        super.init(coder: coder)
        setupTextKit()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    
    private func setupTextKit() {
        // Connect TextKit stack: TextStorage -> LayoutManager -> TextContainer -> TextView
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // Configure text container
        textContainer.lineFragmentPadding = 8
        textContainer.widthTracksTextView = true
        
        // Configure text view
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isScrollEnabled = false
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        // Add scroll view
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        
        // Add text view to scroll view
        scrollView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Text view constraints
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    public func insertText(_ text: String) {
        textView.insertText(text)
    }
    
    public func deleteBackward() {
        textView.deleteBackward()
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    public override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }
    
    public override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
}

// MARK: - UITextViewDelegate

extension MarkdownTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(self)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection(self)
    }
}