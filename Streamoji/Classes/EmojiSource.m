//
//  EmojiSource.m
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import "EmojiSource.h"

@implementation EmojiSource

- (instancetype)initWithType:(EmojiSourceType)type emojiValue:(NSString *)emojiValue {
    self = [super init];
    if (self) {
        _type = type;
        _emojiValue = emojiValue;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSString *typeString = [coder decodeObjectForKey:@"type"];
        if ([typeString isEqualToString:@"character"]) {
            _type = EmojiSourceTypeCharacter;
        } else if ([typeString isEqualToString:@"imageUrl"]) {
            _type = EmojiSourceTypeImageUrl;
        } else if ([typeString isEqualToString:@"imageAsset"]) {
            _type = EmojiSourceTypeImageAsset;
        } else if ([typeString isEqualToString:@"alias"]) {
            _type = EmojiSourceTypeAlias;
        } else {
            // Invalid type
            return nil;
        }
        
        _emojiValue = [coder decodeObjectForKey:@"emojiValue"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:_type forKey:@"type"];
    [encoder encodeObject:_emojiValue forKey:@"emojiValue"];
}

@end
