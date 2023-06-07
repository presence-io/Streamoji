//
//  NSAttributedString+Emoji.h
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import <Foundation/Foundation.h>
#import "EmojiSource.h"
#import "EmojiRendering.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString(Emoji)

- (NSAttributedString *)insertEmojis:(NSDictionary<NSString *, EmojiSource *> *)emojis rendering:(EmojiRendering *)rendering;

@end

@interface NSMutableAttributedString (Emoji)

- (NSArray<NSValue *> *)insertEmojis:(NSDictionary<NSString *, EmojiSource *> *)emojis in:(NSArray<NSValue *> *)ranges rendering:(NSInteger)rendering;

@end

NS_ASSUME_NONNULL_END
