import AppKit

struct URLDetector {
    static func detectAndApplyLinks(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, options: [], range: range)

        for match in matches {
            guard let url = match.url else { continue }
            attributedString.addAttribute(.link, value: url, range: match.range)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
            attributedString.addAttribute(.foregroundColor, value: NSColor.linkColor, range: match.range)
        }
    }
}
