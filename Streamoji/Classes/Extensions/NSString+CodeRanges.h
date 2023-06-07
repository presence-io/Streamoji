//
//  String+CodeRanges.h
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString(CodeRanges)

- (NSArray<NSValue *> *)codeRanges;
- (NSArray<NSValue *> *)filterOutRangesInsideCode:(NSArray<NSValue *> *)ranges;

@end

NS_ASSUME_NONNULL_END
