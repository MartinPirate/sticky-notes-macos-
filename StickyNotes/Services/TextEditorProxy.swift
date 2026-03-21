import AppKit

@Observable
final class TextEditorProxy {
    weak var textView: NSTextView?

    /// Tracks the last known selection so formatting works even after
    /// a SwiftUI button click steals first responder from NSTextView.
    var lastSelectedRange: NSRange = NSRange(location: 0, length: 0)

    func updateSelection(_ range: NSRange) {
        lastSelectedRange = range
    }

    // MARK: - Restore focus and get effective range

    private func restoreFocusAndRange() -> NSRange? {
        guard let textView else { return nil }
        textView.window?.makeFirstResponder(textView)

        // If the textView currently has a selection, use it.
        // Otherwise fall back to the last saved selection.
        let current = textView.selectedRange()
        let effective = current.length > 0 ? current : lastSelectedRange
        if effective.length > 0 {
            textView.setSelectedRange(effective)
        }
        return effective
    }

    // MARK: - Formatting

    func toggleBold() {
        guard let textView, let storage = textView.textStorage else { return }
        guard let range = restoreFocusAndRange() else { return }
        if range.length == 0 {
            toggleTypingAttribute(textView, trait: .boldFontMask)
            return
        }
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            guard let font = value as? NSFont else { return }
            let newFont: NSFont
            if font.fontDescriptor.symbolicTraits.contains(.bold) {
                newFont = NSFontManager.shared.convert(font, toNotHaveTrait: .boldFontMask)
            } else {
                newFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
            }
            storage.addAttribute(.font, value: newFont, range: attrRange)
        }
        storage.endEditing()
        textView.setSelectedRange(range)
        notifyChange(textView)
    }

    func toggleItalic() {
        guard let textView, let storage = textView.textStorage else { return }
        guard let range = restoreFocusAndRange() else { return }
        if range.length == 0 {
            toggleTypingAttribute(textView, trait: .italicFontMask)
            return
        }
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            guard let font = value as? NSFont else { return }
            let newFont: NSFont
            if font.fontDescriptor.symbolicTraits.contains(.italic) {
                newFont = NSFontManager.shared.convert(font, toNotHaveTrait: .italicFontMask)
            } else {
                newFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
            }
            storage.addAttribute(.font, value: newFont, range: attrRange)
        }
        storage.endEditing()
        textView.setSelectedRange(range)
        notifyChange(textView)
    }

    func toggleUnderline() {
        guard let textView, let storage = textView.textStorage else { return }
        guard let range = restoreFocusAndRange() else { return }
        if range.length == 0 {
            var attrs = textView.typingAttributes
            let current = (attrs[.underlineStyle] as? Int) ?? 0
            attrs[.underlineStyle] = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            textView.typingAttributes = attrs
            return
        }
        storage.beginEditing()
        storage.enumerateAttribute(.underlineStyle, in: range) { value, attrRange, _ in
            let current = (value as? Int) ?? 0
            let newValue = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            storage.addAttribute(.underlineStyle, value: newValue, range: attrRange)
        }
        storage.endEditing()
        textView.setSelectedRange(range)
        notifyChange(textView)
    }

    func toggleStrikethrough() {
        guard let textView, let storage = textView.textStorage else { return }
        guard let range = restoreFocusAndRange() else { return }
        if range.length == 0 {
            var attrs = textView.typingAttributes
            let current = (attrs[.strikethroughStyle] as? Int) ?? 0
            attrs[.strikethroughStyle] = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            textView.typingAttributes = attrs
            return
        }
        storage.beginEditing()
        storage.enumerateAttribute(.strikethroughStyle, in: range) { value, attrRange, _ in
            let current = (value as? Int) ?? 0
            let newValue = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            storage.addAttribute(.strikethroughStyle, value: newValue, range: attrRange)
        }
        storage.endEditing()
        textView.setSelectedRange(range)
        notifyChange(textView)
    }

    func toggleBulletList() {
        guard let textView else { return }
        _ = restoreFocusAndRange()
        let text = textView.string as NSString
        let selectedRange = textView.selectedRange()
        let effectiveRange = selectedRange.length > 0 ? selectedRange : lastSelectedRange
        let lineRange = text.lineRange(for: effectiveRange)
        let lineText = text.substring(with: lineRange)

        let lines = lineText.components(separatedBy: "\n")
        let nonEmpty = lines.filter { !$0.isEmpty }
        let allBulleted = !nonEmpty.isEmpty && nonEmpty.allSatisfy { $0.hasPrefix("• ") }

        var newLines: [String] = []
        for line in lines {
            if line.isEmpty {
                newLines.append(line)
            } else if allBulleted {
                newLines.append(String(line.dropFirst(2)))
            } else if !line.hasPrefix("• ") {
                newLines.append("• " + line)
            } else {
                newLines.append(line)
            }
        }

        let newText = newLines.joined(separator: "\n")
        textView.insertText(newText, replacementRange: lineRange)
        notifyChange(textView)
    }

    private func toggleTypingAttribute(_ textView: NSTextView, trait: NSFontTraitMask) {
        var attrs = textView.typingAttributes
        let font = (attrs[.font] as? NSFont) ?? NSFont.systemFont(ofSize: 14)
        let hasTrait: Bool
        if trait == .boldFontMask {
            hasTrait = font.fontDescriptor.symbolicTraits.contains(.bold)
        } else {
            hasTrait = font.fontDescriptor.symbolicTraits.contains(.italic)
        }
        if hasTrait {
            attrs[.font] = NSFontManager.shared.convert(font, toNotHaveTrait: trait)
        } else {
            attrs[.font] = NSFontManager.shared.convert(font, toHaveTrait: trait)
        }
        textView.typingAttributes = attrs
    }

    private func notifyChange(_ textView: NSTextView) {
        NotificationCenter.default.post(
            name: NSText.didChangeNotification,
            object: textView
        )
    }
}
