//
//  UITextView+Emojis.h
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import <Foundation/Foundation.h>
#import "EmojiSource.h"
#import "EmojiRendering.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (Emojis)

- (void)configureEmojis:(NSDictionary<NSString *, EmojiSource *> *)emojis;
- (void)configureEmojis:(NSDictionary<NSString *, EmojiSource *> *)emojis rendering:(EmojiRendering *)rendering;

@end

NS_ASSUME_NONNULL_END
