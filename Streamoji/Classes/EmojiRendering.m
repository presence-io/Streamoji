//
//  EmojiRendering.m
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import "EmojiRendering.h"

@implementation EmojiRendering

- (instancetype)initWithQuality:(EmojiRenderingQuality)quality scale:(float)scale {
    self = [super init];
    if (self) {
        _quality = quality;
        _scale = scale;
    }
    return self;
}

@end

@interface EmojiRendering (Extensions)

@property (class, nonatomic, readonly) EmojiRendering *highestQuality;
@property (class, nonatomic, readonly) EmojiRendering *highQuality;
@property (class, nonatomic, readonly) EmojiRendering *mediumQuality;
@property (class, nonatomic, readonly) EmojiRendering *lowQuality;
@property (class, nonatomic, readonly) EmojiRendering *lowestQuality;

@end

@implementation EmojiRendering (Extensions)

+ (EmojiRendering *)highestQuality {
    return [[EmojiRendering alloc] initWithQuality:EmojiRenderingQualityHighest scale:1.0];
}

+ (EmojiRendering *)highQuality {
    return [[EmojiRendering alloc] initWithQuality:EmojiRenderingQualityHigh scale:1.0];
}

+ (EmojiRendering *)mediumQuality {
    return [[EmojiRendering alloc] initWithQuality:EmojiRenderingQualityMedium scale:1.0];
}

+ (EmojiRendering *)lowQuality {
    return [[EmojiRendering alloc] initWithQuality:EmojiRenderingQualityLow scale:1.0];
}

+ (EmojiRendering *)lowestQuality {
    return [[EmojiRendering alloc] initWithQuality:EmojiRenderingQualityLowest scale:1.0];
}

@end
