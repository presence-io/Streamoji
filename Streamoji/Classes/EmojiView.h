//
//  EmojiView.h
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import <Foundation/Foundation.h>
#import "EmojiRendering.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmojiView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

- (void)setFromRenderView:(UIImageView *)view;

@end

@interface UIImageView (Internal)

- (void)setFromURL:(NSURL *)url rendering:(EmojiRendering *)rendering;

- (void)setFromAsset:(NSString *)name rendering:(EmojiRendering*)rendering;

@end

NS_ASSUME_NONNULL_END
