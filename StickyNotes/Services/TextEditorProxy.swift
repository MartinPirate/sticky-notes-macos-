import AppKit

// Custom attribute key for hidden/spoiler text
extension NSAttributedString.Key {
    static let hiddenText = NSAttributedString.Key("com.stickynotes.hiddenText")
}

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

        let current = textView.selectedRange()
        let effective = current.length > 0 ? current : lastSelectedRange
        if effective.length > 0 {
            textView.setSelectedRange(effective)
        }
        return effective
    }

    // MARK: - Text Formatting

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

    // MARK: - Todo List

    func toggleTodoList() {
        guard let textView else { return }
        _ = restoreFocusAndRange()
        let text = textView.string as NSString
        let selectedRange = textView.selectedRange()
        let effectiveRange = selectedRange.length > 0 ? selectedRange : lastSelectedRange
        let lineRange = text.lineRange(for: effectiveRange)
        let lineText = text.substring(with: lineRange)

        let lines = lineText.components(separatedBy: "\n")
        let nonEmpty = lines.filter { !$0.isEmpty }
        let allTodo = !nonEmpty.isEmpty && nonEmpty.allSatisfy {
            $0.hasPrefix("☐ ") || $0.hasPrefix("☑ ")
        }

        var newLines: [String] = []
        for line in lines {
            if line.isEmpty {
                newLines.append(line)
            } else if allTodo {
                // Remove todo prefix
                if line.hasPrefix("☐ ") || line.hasPrefix("☑ ") {
                    newLines.append(String(line.dropFirst(2)))
                } else {
                    newLines.append(line)
                }
            } else if !line.hasPrefix("☐ ") && !line.hasPrefix("☑ ") {
                newLines.append("☐ " + line)
            } else {
                newLines.append(line)
            }
        }

        let newText = newLines.joined(separator: "\n")
        textView.insertText(newText, replacementRange: lineRange)
        notifyChange(textView)
    }

    /// Toggle a single todo line between ☐ and ☑ at the given character index
    func toggleTodoAt(characterIndex: Int) {
        guard let textView else { return }
        let text = textView.string as NSString
        let clickRange = NSRange(location: characterIndex, length: 0)
        let lineRange = text.lineRange(for: clickRange)
        let lineText = text.substring(with: lineRange)

        var newLine = lineText
        if lineText.hasPrefix("☐ ") {
            newLine = "☑ " + String(lineText.dropFirst(2))
        } else if lineText.hasPrefix("☑ ") {
            newLine = "☐ " + String(lineText.dropFirst(2))
        } else {
            return
        }

        textView.insertText(newLine, replacementRange: lineRange)

        // Apply strikethrough to completed items
        let newLineRange = NSRange(location: lineRange.location, length: (newLine as NSString).length)
        if newLine.hasPrefix("☑ ") {
            textView.textStorage?.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: newLineRange)
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: newLineRange)
        } else {
            textView.textStorage?.removeAttribute(.strikethroughStyle, range: newLineRange)
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.textColor, range: newLineRange)
        }

        notifyChange(textView)
    }

    // MARK: - Hidden/Spoiler Text

    func toggleHiddenText() {
        guard let textView, let storage = textView.textStorage else { return }
        guard let range = restoreFocusAndRange(), range.length > 0 else { return }

        // Check if already hidden
        var isHidden = false
        storage.enumerateAttribute(.hiddenText, in: range) { value, _, stop in
            if value as? Bool == true {
                isHidden = true
                stop.pointee = true
            }
        }

        storage.beginEditing()
        if isHidden {
            // Reveal: remove hidden attribute, restore original color
            storage.removeAttribute(.hiddenText, range: range)
            storage.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)
            storage.removeAttribute(.backgroundColor, range: range)
        } else {
            // Hide: mark as hidden, set text color to match background
            storage.addAttribute(.hiddenText, value: true, range: range)
            storage.addAttribute(.foregroundColor, value: NSColor.black, range: range)
            storage.addAttribute(.backgroundColor, value: NSColor.black, range: range)
        }
        storage.endEditing()
        textView.setSelectedRange(range)
        notifyChange(textView)
    }

    /// Reveal hidden text at a click location
    func revealHiddenTextAt(characterIndex: Int) {
        guard let textView, let storage = textView.textStorage else { return }
        let fullRange = NSRange(location: 0, length: storage.length)

        // Find the hidden text range containing this index
        storage.enumerateAttribute(.hiddenText, in: fullRange) { value, attrRange, stop in
            guard value as? Bool == true,
                  NSLocationInRange(characterIndex, attrRange) else { return }

            storage.beginEditing()
            storage.removeAttribute(.hiddenText, range: attrRange)
            storage.addAttribute(.foregroundColor, value: NSColor.textColor, range: attrRange)
            storage.removeAttribute(.backgroundColor, range: attrRange)
            storage.endEditing()
            notifyChange(textView)
            stop.pointee = true
        }
    }

    // MARK: - Private

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
