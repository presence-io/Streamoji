//
//  UITextView+Emojis.m
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import "UITextView+Emojis.h"
#import "EmojiSource.h"
#import "EmojiView.h"
#import "NSAttributedString+Emoji.h"

@interface UITextView ()

@property (nonatomic, strong) UIView *textContainerView;

@end

@implementation UITextView(Emojis)

static NSMutableDictionary<EmojiSource *, UIImageView *> *renderViews;

+ (void)initialize {
    if (self == [UITextView class]) {
        renderViews = [NSMutableDictionary dictionary];
    }
}

- (void)configureEmojis:(NSDictionary<NSString *, id> *)emojis {
    [self configureEmojis:emojis rendering:EmojiRendering.highQuality];
}

- (void)configureEmojis:(NSDictionary<NSString *, id> *)emojis rendering:(EmojiRendering *)rendering {
    [self applyEmojis:emojis rendering:rendering];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self applyEmojis:emojis rendering:rendering];
    }];
}

- (UIView *)textContainerView {
    return self.subviews[1];
}

- (NSArray<EmojiView *> *)customEmojiViews {
    NSMutableArray<EmojiView *> *views = [NSMutableArray array];
    for (UIView *subview in self.textContainerView.subviews) {
        if ([subview isKindOfClass:[EmojiView class]]) {
            [views addObject:(EmojiView *)subview];
        }
    }
    return views;
}

- (void)applyEmojis:(NSDictionary<NSString *, EmojiSource *> *)emojis rendering:(EmojiRendering *)rendering {
    NSRange range = self.selectedRange;
    NSInteger count = self.attributedText.string.length;
    self.attributedText = [self.attributedText insertEmojis:emojis rendering:rendering];
    NSInteger newCount = self.attributedText.string.length;
    
    for (UIView *view in self.customEmojiViews) {
        [view removeFromSuperview];
    }
    
    [self addEmojiImagesIfNeededWithRendering:rendering];
    
    self.selectedRange = NSMakeRange(range.location - (count - newCount), range.length);
}

- (void)addEmojiImagesIfNeededWithRendering:(EmojiRendering *)rendering {
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attributes, NSRange crange, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTextAttachment *emojiAttachment = attributes[NSAttachmentAttributeName];
            UITextPosition *position1 = [self positionFromPosition:self.beginningOfDocument offset:crange.location];
            UITextPosition *position2 = [self positionFromPosition:position1 offset:crange.length];
            UITextRange *textRange = [self textRangeFromPosition:position1 toPosition:position2];
            NSData *emojiData = emojiAttachment.contents;
            EmojiSource *emoji = nil;
            
            if ([emojiData isKindOfClass:[NSData class]]) {
                @try {
                    emoji = [NSJSONSerialization JSONObjectWithData:emojiData options:0 error:nil];
                } @catch (NSException *exception) {
                    // JSON decoding failed
                }
            }
            
            if (!emoji) {
                return;
            }
            
            CGRect rect = [self firstRectForRange:textRange];
            
            EmojiView *emojiView = [[EmojiView alloc] initWithFrame:rect];
            emojiView.backgroundColor = self.backgroundColor;
            emojiView.userInteractionEnabled = NO;
            
            if ([emoji isKindOfClass:[EmojiSource class]]) {
                switch (emoji.type) {
                    case EmojiSourceTypeCharacter:
                        emojiView.label.text = emoji.emojiValue;
                        break;
                    case EmojiSourceTypeImageUrl:
                        if (![renderViews objectForKey:emoji]) {
                            if (emoji.emojiValue) {
                                NSURL *url = [NSURL URLWithString:emoji.emojiValue];
                                UIImageView *renderView = [[UIImageView alloc] initWithFrame:rect];
                                [renderView setFromURL:url rendering:rendering];
                                [renderViews setObject:renderView forKey:emoji];
                                [self.window addSubview:renderView];
                                renderView.alpha = 0;
                            }
                        }
                        break;
                    case EmojiSourceTypeImageAsset:
                        if (![renderViews objectForKey:emoji]) {
                            UIImageView *renderView = [[UIImageView alloc] initWithFrame:rect];
                            [renderView setFromAsset:emoji.emojiValue rendering:rendering];
                            [renderViews setObject:renderView forKey:emoji];
                            [self.window addSubview:renderView];
                            renderView.alpha = 0;
                        }
                        break;
                    case EmojiSourceTypeAlias:
                        break;
                }
                
                UIImageView *view = [renderViews objectForKey:emoji];
                
                if (view) {
                    [emojiView setFromRenderView:view];
                }
            }
            
            [self.textContainerView addSubview:emojiView];
        });
    }];
}

@end
