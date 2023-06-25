//
//  NSAttributedString+Emojis.swift
//  Streamoji
//
//  Created by Matheus Cardoso on 30/06/20.
//

import UIKit

extension NSAttributedString {
    internal func insertingEmojis(
        _ emojis: [String: EmojiSource],
        rendering: EmojiRendering,
        font : UIFont?
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        var ranges = attributedString.getMatches()
        let notMatched = attributedString.insertEmojis(
            emojis,
            in: string.filterOutRangesInsideCode(ranges: ranges),
            rendering: rendering,
            font: font
        )
        ranges = attributedString.getMatches(excludingRanges: notMatched)
        attributedString.insertEmojis(
            emojis,
            in: string.filterOutRangesInsideCode(ranges: ranges),
            rendering: rendering,
            font: font
        )

        return attributedString
    }
    
    private func getMatches(
        excludingRanges: [NSRange] = []
    ) -> [NSRange] {
        var ranges = [NSRange]()
        var lastMatchIndex = 0
        for range in excludingRanges {
            ranges.append(NSRange(location: lastMatchIndex, length: range.location - lastMatchIndex + 1))
            lastMatchIndex = range.location + range.length - 1
        }
        ranges.append(NSRange(location: lastMatchIndex, length: length - lastMatchIndex))

        let regex = try? NSRegularExpression(pattern: ":(\\w|-|\\+)+:", options: [])
        let matchRanges = ranges.map { range in regex?.matches(in: string, options: [], range: range).map { $0.range(at: 0) } ?? [] }
        return matchRanges.reduce(into: [NSRange]()) { $0.append(contentsOf: $1) }
    }
}

extension NSMutableAttributedString {
    
    @discardableResult
    internal func insertEmojis(
        _ emojis: [String: EmojiSource],
        in ranges: [NSRange],
        rendering: EmojiRendering,
        font : UIFont?
    ) -> [NSRange] {
        var offset = 0
        var notMatched = [NSRange]()

        for range in ranges {
            let transformedRange = NSRange(location: range.location - offset, length: range.length)
            let replacementString = self.attributedSubstring(from: transformedRange)
            var theFont = font;
            if let replacementFont = replacementString.attribute(.font, at: 0, effectiveRange: .none) as? UIFont {
                theFont = replacementFont
            }
            let paragraphStyle = replacementString.attribute(.paragraphStyle, at: 0, effectiveRange: .none) as? NSParagraphStyle
            
            let emojiAttachment = NSTextAttachment()
            let fontSize = (theFont?.pointSize ?? 22.0) * CGFloat(rendering.scale)
            var spacing : CGFloat = 0;
            if #available(iOS 15.0, *) {
                spacing = 1.0
                emojiAttachment.lineLayoutPadding = spacing
            }
            emojiAttachment.bounds = CGRect(x: 0, y: fontSize * -0.23, width: fontSize * 1.23 + spacing * 2, height: fontSize * 1.23)
            
            let emojiAttributedString = NSMutableAttributedString(attachment: emojiAttachment)
            
            if let font = font, let paragraphStyle = paragraphStyle {
                emojiAttributedString.setAttributes(
                    [.font: font, .paragraphStyle: paragraphStyle, .attachment: emojiAttachment],
                    range: .init(location: 0, length: emojiAttributedString.length)
                )
            }

            if var emoji = emojis[replacementString.string.replacingOccurrences(of: ":", with: "")] {
                if case .alias(let alias) = emoji {
                    emoji = emojis[alias] ?? emoji
                }
                
                emojiAttachment.contents = try! JSONEncoder().encode(emoji)
                if case let .imageAsset(value) = emoji {
                    if let asset = NSDataAsset(name: value),
                       let gifImage = try? UIImage(gifData: asset.data, levelOfIntegrity: rendering.gifLevelOfIntegrity) {
                        if let imageData = gifImage.imageData, (gifImage.imageCount ?? 0) < 1 {
                            let image = UIImage(data: imageData)
                            emojiAttachment.image = image
                        }
                    } else if let image = UIImage(named: value) {
                        emojiAttachment.image = image
                    } else {
                        let fileURL = URL(fileURLWithPath: value)
                        let fileExtension = fileURL.pathExtension // 获取文件扩展名
                        let fileName = fileURL.deletingPathExtension().lastPathComponent
                        if let filePath = Bundle.main.path(forResource: fileName, ofType: fileExtension, inDirectory: "Data/Raw/Emojis") {
                            if let image = UIImage(contentsOfFile: filePath) {
                                emojiAttachment.image = image
                            }
                        }
                    }
                }
                emojiAttributedString.addAttributes(
                    [.emojiName: replacementString.string],
                    range: .init(location: 0, length: emojiAttributedString.length)
                )
                self.replaceCharacters(
                    in: transformedRange,
                    with: emojiAttributedString
                )

                offset += replacementString.length - 1
            } else {
                notMatched.append(transformedRange)
            }
        }

        return notMatched
    }
}

extension NSAttributedString.Key {
    
    public static let emojiName: NSAttributedString.Key = NSAttributedString.Key(rawValue: "emojiname")
    
}
