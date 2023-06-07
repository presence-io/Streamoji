//
//  String+CodeRanges.m
//  Streamoji
//
//  Created by User on 2023/6/7.
//

#import "NSString+CodeRanges.h"

@implementation NSAttributedString(CodeRanges)

- (NSArray<NSValue *> *)codeRanges {
    NSRegularExpression *codeRegex = [NSRegularExpression regularExpressionWithPattern:@"(```)(?:[a-zA-Z]+)?((?:.|\r|\n)*?)(```)" options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSArray<NSTextCheckingResult *> *codeMatches = [codeRegex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    NSMutableArray<NSValue *> *result = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in codeMatches) {
        NSRange range = [match rangeAtIndex:0];
        [result addObject:[NSValue valueWithRange:range]];
    }
    
    return result;
}

- (NSArray<NSValue *> *)filterOutRangesInsideCode:(NSArray<NSValue *> *)ranges {
    NSArray<NSValue *> *codeRanges = [self codeRanges];
    
    NSArray<NSValue *> *filteredRanges = [ranges filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSValue *rangeValue, NSDictionary *bindings) {
        NSRange range = [rangeValue rangeValue];
        
        for (NSValue *codeRangeValue in codeRanges) {
            NSRange codeRange = [codeRangeValue rangeValue];
            if (NSIntersectionRange(codeRange, range).length == range.length) {
                return NO;
            }
        }
        
        return YES;
    }]];
    
    return filteredRanges;
}


@end
