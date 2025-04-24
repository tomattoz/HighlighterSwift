//  Created by Ivan Khvorostinin on 24.04.2025.

import SwiftUI

#if os(OSX)
import AppKit
public typealias HighlighterViewContent = NSScrollView
#elseif os(iOS)
import UIKit
public typealias NSViewRepresentable = UIViewRepresentable
public typealias NSTextViewDelegate = UITextViewDelegate

#endif

public struct HighlighterView: NSViewRepresentable {
    @Binding var text: String
    let theme: String?
    let language: String?

    public init(text: Binding<String>, theme: String? = nil, language: String? = nil) {
        _text = .init(projectedValue: text)
        self.theme = theme
        self.language = language
    }
    
    private func applyProperties(to textView: HighlighterTextView) {
        if textView.code != text {
            textView.code = text
        }
        
        if let theme {
            textView.highlighterTextStorage.highlighter?.setTheme(theme)
        }
        
        if let language {
            textView.highlighterTextStorage.language = language
        }
    }

#if os(OSX)
    public func makeNSView(context: Context) -> NSScrollView {
        let textView = HighlighterTextView(frame: .zero)
        textView.delegate = context.coordinator
        applyProperties(to: textView)

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.documentView = textView
        
        return scrollView
    }
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = nsView.documentView as? HighlighterTextView {
            applyProperties(to: textView)
        }
    }
        
#elseif os(iOS)
    public func makeUIView(context: Context) -> HighlighterTextView {
        let textView = HighlighterTextView(frame: .zero)
        textView.delegate = context.coordinator
        applyProperties(to: textView)
        return textView
    }
    
    public func updateUIView(_ nsView: HighlighterTextView, context: Context) {
        applyProperties(to: nsView)
    }
#endif

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        public func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
#if os(OSX)
                self.text = textView.string
#elseif os(iOS)
                self.text = textView.text
#endif
            }
        }
    }
}
