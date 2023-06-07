//
//  NSAttributedString+Emoji.m
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import "NSAttributedString+Emoji.h"
#import "NSString+CodeRanges.h"
#import "EmojiSource.h"

@implementation NSAttributedString(Emoji)

- (NSAttributedString *)insertingEmojis:(NSDictionary<NSString *, id> *)emojis rendering:(EmojiRendering *)rendering {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self];

    NSMutableArray<NSValue *> *ranges = [self getMatches:@[]];
    NSArray<NSValue *> *notMatched = [attributedString insertEmojis:emojis in:[self filterOutRangesInsideCode:ranges] rendering:rendering];
    ranges = [attributedString getMatches:notMatched];
    [attributedString insertEmojis:emojis in:[self filterOutRangesInsideCode:ranges] rendering:rendering];

    return attributedString;
}

- (NSArray<NSValue *> *)getMatches:(NSArray<NSValue *> *)excludingRanges {
    NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
    NSInteger lastMatchIndex = 0;
    
    for (NSValue *rangeValue in excludingRanges) {
        NSRange range = [rangeValue rangeValue];
        NSRange newRange = NSMakeRange(lastMatchIndex, range.location - lastMatchIndex + 1);
        [ranges addObject:[NSValue valueWithRange:newRange]];
        lastMatchIndex = range.location + range.length - 1;
    }
    
    NSRange remainingRange = NSMakeRange(lastMatchIndex, self.length - lastMatchIndex);
    [ranges addObject:[NSValue valueWithRange:remainingRange]];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":(\\w|-|\\+)+:" options:0 error:nil];
    
    NSMutableArray<NSValue *> *matchRanges = [NSMutableArray array];
    
    for (NSValue *rangeValue in ranges) {
        NSRange range = [rangeValue rangeValue];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:self options:0 range:range];
        
        for (NSTextCheckingResult *result in matches) {
            NSRange matchRange = [result rangeAtIndex:0];
            [matchRanges addObject:[NSValue valueWithRange:matchRange]];
        }
    }
    
    return [matchRanges copy];
}

@end

@implementation NSMutableAttributedString (Emoji)

- (NSArray<NSValue *> *)insertEmojis:(NSDictionary<NSString *, id> *)emojis in:(NSArray<NSValue *> *)ranges rendering:(NSInteger)rendering {
    NSInteger offset = 0;
    NSMutableArray<NSValue *> *notMatched = [[NSMutableArray alloc] init];

    for (NSValue *rangeValue in ranges) {
        NSRange range = [rangeValue rangeValue];
        NSRange transformedRange = NSMakeRange(range.location - offset, range.length);
        NSAttributedString *replacementString = [self attributedSubstringFromRange:transformedRange];
        UIFont *font = [replacementString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        NSParagraphStyle *paragraphStyle = [replacementString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];

        NSTextAttachment *emojiAttachment = [[NSTextAttachment alloc] init];
        CGFloat fontSize = ([font pointSize] ?: 22.0) * rendering;
        emojiAttachment.bounds = CGRectMake(0, 0, fontSize, fontSize);

        NSMutableAttributedString *emojiAttributedString = [NSMutableAttributedString attributedStringWithAttachment:emojiAttachment];

        if (font && paragraphStyle) {
            [emojiAttributedString setAttributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle, NSAttachmentAttributeName: emojiAttachment} range:NSMakeRange(0, [emojiAttributedString length])];
        }

        NSString *replacementStringWithoutColons = [[replacementString string] stringByReplacingOccurrencesOfString:@":" withString:@""];
        EmojiSource *emoji = emojis[replacementStringWithoutColons];
        if ([emoji isKindOfClass:[NSNumber class]]) {
            EmojiSourceType type = emoji.type;
            switch (type) {
                case EmojiSourceTypeAlias: {
                    NSString *alias = (NSString *)emoji;
                    emoji = emojis[alias] ?: emoji;
                    break;
                }
                default:
                    break;
            }
        }

        if (emoji) {
            emojiAttachment.contents = [NSJSONSerialization dataWithJSONObject:emoji options:0 error:nil];
            [self replaceCharactersInRange:transformedRange withAttributedString:emojiAttributedString];

            offset += [replacementString length] - 1;
        } else {
            [notMatched addObject:[NSValue valueWithRange:transformedRange]];
        }
    }

    return notMatched;
}

@end
