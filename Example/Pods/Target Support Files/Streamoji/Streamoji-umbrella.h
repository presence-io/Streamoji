#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "EmojiRendering.h"
#import "EmojiSource.h"
#import "EmojiView.h"
#import "NSAttributedString+Emoji.h"
#import "NSString+CodeRanges.h"
#import "UITextView+Emojis.h"

FOUNDATION_EXPORT double StreamojiVersionNumber;
FOUNDATION_EXPORT const unsigned char StreamojiVersionString[];

