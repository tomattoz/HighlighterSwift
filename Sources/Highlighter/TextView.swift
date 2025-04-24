//  Created by Ivan Khvorostinin on 24.04.2025.

#if os(OSX)
import AppKit
#elseif os(iOS)
import UIKit
public typealias NSTextView = UITextView
public typealias NSRect = CGRect

extension NSTextView {
    var string: String {
        get { text }
        set { text = newValue }
    }
}
#endif

public class HighlighterTextView: NSTextView {
    public let highlighterTextStorage = HighlighterTextStorage()

    public override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setupTextStorage()
        configureTextView()
    }
    
#if os(OSX)
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTextStorage()
        configureTextView()
    }
#elseif os(iOS)
    public init(frame frameRect: NSRect) {
        super.init(frame: frameRect, textContainer: nil)
        setupTextStorage()
        configureTextView()
    }
#endif

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextStorage()
        configureTextView()
    }
    
    public var code: String {
        get {
            string
        }
        set {
            let language = highlighterTextStorage.language
            let attributedString = highlighterTextStorage
                .highlighter?
                .highlight(newValue, as: language)
            
            if let attributedString {
                let textStorage: NSTextStorage? = textStorage
                textStorage?.setAttributedString(attributedString)
            }
            else {
                string = newValue
            }
        }
    }
    
    private func setupTextStorage() {
        let existingLayoutManager: NSLayoutManager? = self.layoutManager
        
        if let existingLayoutManager {
            // Replace the existing text storage in the layout manager
            if let oldTextStorage = existingLayoutManager.textStorage,
               oldTextStorage !== highlighterTextStorage {
#if os(OSX)
                existingLayoutManager.replaceTextStorage(highlighterTextStorage)
#elseif os(iOS)
                existingLayoutManager.textStorage = highlighterTextStorage
#endif

            } else if !highlighterTextStorage.layoutManagers.contains(existingLayoutManager) {
                // If no text storage exists, add the new one to the layout manager
                highlighterTextStorage.addLayoutManager(existingLayoutManager)
            }
        } else {
#if os(OSX)
            // Create a new text container and layout manager
            let textContainer = NSTextContainer()
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            highlighterTextStorage.addLayoutManager(layoutManager)
            
            // Assign the text container to the text view
            self.textContainer = textContainer
#elseif os(iOS)
            // Create a new text container and layout manager
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            highlighterTextStorage.addLayoutManager(layoutManager)
#endif
        }
    }
    
    // Configure text view properties
    private func configureTextView() {
        let textContainer: NSTextContainer? = self.textContainer
        
#if os(OSX)
        self.isRichText = true
        self.allowsUndo = true
        self.isHorizontallyResizable = false
        self.isVerticallyResizable   = true
        self.autoresizingMask = .width
#elseif os(iOS)
        self.autoresizingMask = .flexibleWidth
#endif
        self.isEditable = true
        self.isSelectable = true
        textContainer?.heightTracksTextView = false
        textContainer?.widthTracksTextView = true
    }
}
