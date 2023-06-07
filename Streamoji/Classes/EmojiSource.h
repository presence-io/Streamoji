//
//  EmojiSource.h
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EmojiSourceType) {
    EmojiSourceTypeCharacter,
    EmojiSourceTypeImageUrl,
    EmojiSourceTypeImageAsset,
    EmojiSourceTypeAlias
};

@interface EmojiSource : NSObject<NSCopying>

@property (nonatomic, assign) EmojiSourceType type;

@property (nonatomic, strong) NSString *emojiValue;

- (instancetype)initWithType:(EmojiSourceType)type emojiValue:(NSString *)emojiValue;

@end

NS_ASSUME_NONNULL_END
