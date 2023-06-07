//
//  EmojiRendering.h
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EmojiRenderingQuality) {
    EmojiRenderingQualityLowest,
    EmojiRenderingQualityLow,
    EmojiRenderingQualityMedium,
    EmojiRenderingQualityHigh,
    EmojiRenderingQualityHighest
};

@interface EmojiRendering : NSObject

@property (nonatomic, assign) EmojiRenderingQuality quality;
@property (nonatomic, assign) float scale;

- (instancetype)initWithQuality:(EmojiRenderingQuality)quality scale:(float)scale;

@end

@interface EmojiRendering (Extensions)

+ (EmojiRendering *)highestQuality;

+ (EmojiRendering *)highQuality;

+ (EmojiRendering *)mediumQuality;

+ (EmojiRendering *)lowQuality;

+ (EmojiRendering *)lowestQuality;

@end

