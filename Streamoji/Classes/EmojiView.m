//
//  EmojiView.m
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import "EmojiView.h"
#import "EmojiRendering.h"

typedef NS_ENUM(NSInteger, GifLevelOfIntegrity) {
    GifLevelOfIntegrityHighestNoFrameSkipping,
    GifLevelOfIntegrityDefault,
    GifLevelOfIntegrityLowForManyGifs,
    GifLevelOfIntegrityLowForTooManyGifs,
    GifLevelOfIntegritySuperLowForSlideShow
};

@interface EmojiRendering (Internal)
- (GifLevelOfIntegrity)gifLevelOfIntegrity;
@end

@implementation EmojiRendering (Internal)

- (GifLevelOfIntegrity)gifLevelOfIntegrity {
    switch (self.quality) {
        case EmojiRenderingQualityHighest: return GifLevelOfIntegrityHighestNoFrameSkipping;
        case EmojiRenderingQualityHigh: return GifLevelOfIntegrityDefault;
        case EmojiRenderingQualityMedium: return GifLevelOfIntegrityLowForManyGifs;
        case EmojiRenderingQualityLow: return GifLevelOfIntegrityLowForTooManyGifs;
        case EmojiRenderingQualityLowest: return GifLevelOfIntegritySuperLowForSlideShow;
    }
}

@end

@implementation UIImageView (Internal)

- (void)setFromURL:(NSURL *)url rendering:(EmojiRendering *)rendering {
    // TODO:JINXING
//    Nuke_ImagePipeline_Configuration.isAnimatedImageDataEnabled = YES;
//    [Nuke_ImagePipeline.sharedPipeline loadImageWithURL:url completion:^(UIImage * _Nullable image, NSError * _Nullable error, Nuke_ImageLoadingOptions * _Nonnull options, Nuke_ImageResponse * _Nullable response) {
//        if (error) {
//            return;
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (image) {
//                NSData *animation = response.image.animatedImageData;
//                UIImage *gifImage = [[UIImage alloc] initWithAnimatedImageData:animation levelOfIntegrity:[rendering gifLevelOfIntegrity] error:nil];
//
//                if (gifImage) {
//                    [self setGifImage:gifImage];
//                    [self startAnimating];
//                } else {
//                    CGImageRef cgImage = response.image.CGImage;
//                    if (cgImage) {
//                        [self setImage:[[UIImage alloc] initWithCGImage:cgImage]];
//                    }
//                }
//            }
//        });
//    }];
}

- (void)setFromAsset:(NSString *)name rendering:(EmojiRendering *)rendering {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDataAsset *asset = [[NSDataAsset alloc] initWithName:name];
        if (asset) {
//            UIImage *gifImage = [UIImage animatedImageWithAnimatedGIFData:asset.data levelOfIntegrity:rendering.gifLevelOfIntegrity error:nil];
//            if (gifImage) {
//                [self setGifImage:gifImage];
//                [self startAnimating];
//            }
        } else {
            UIImage *image = [UIImage imageNamed:name];
            if (image) {
                [self setImage:image];
            }
        }
    });
}

@end

@implementation EmojiView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.imageView = [[UIImageView alloc] init];
    self.label = [[UILabel alloc] init];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.label.font = [UIFont systemFontOfSize:self.frame.size.width / 1.1];
    self.label.numberOfLines = 0;
    
    [self addSubview:self.imageView];
    [self addSubview:self.label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
    self.imageView.frame = self.bounds;
}

- (void)setFromRenderView:(UIImageView *)view {
    self.imageView.image = view.image;
    __weak typeof(self) weakSelf = self;
    [view addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        if (object == _imageView) {
            _imageView.image = _imageView.image;
        }
    }
}

- (void)dealloc {
    [_imageView removeObserver:self forKeyPath:@"image"];
}

@end
