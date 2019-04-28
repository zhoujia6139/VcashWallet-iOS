//
//  NSNumber+Utils.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "NSNumber+Utils.h"

@implementation NSNumber (Utils)

- (NSString *)p12fString{
    return [self formatP12f];
}

- (NSString *)p9fString{
    return [self formatP9f];
}

- (NSString *)p3fString{
    return [self formatP3f];
}

- (NSString *)p02fString{
    return [self formatP02f];
}

- (NSString *)p06fString{
    return [self formatP06f];
}

- (NSString *)p0fString{
    return [self formatP0f];
}

- (NSString *)formatP02f{
    return [NSString stringWithFormat:@"%.02f", [[self formatP2f] doubleValue]];
}

- (NSString *)formatP06f{
    return [NSString stringWithFormat:@"%.06f", [[self formatP6f] doubleValue]];
}

- (NSString *)formatP12f{
    return [self roundCeilingStringWithScale:12];
}

- (NSString *)formatP6f{
    return [self roundCeilingStringWithScale:6];
}

- (NSString *)formatP9f{
    return [self roundCeilingStringWithScale:9];
}

- (NSString *)formatP3f{
    return [self roundCeilingStringWithScale:3];
}

- (NSString *)formatP2f{
    return [self roundCeilingStringWithScale:2];
}

- (NSString *)formatP0f{
    return [self roundCeilingStringWithScale:0];
}

- (NSString *)scientificNotationString{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    formatter.usesSignificantDigits = true;
    formatter.maximumSignificantDigits = 20;
    NSString * string = [formatter stringFromNumber:self];
    return string;
}


- (NSString *)roundCeilingStringWithScale:(NSInteger)scale{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.roundingMode = NSNumberFormatterRoundCeiling;
    formatter.usesGroupingSeparator = NO;
    formatter.maximumFractionDigits = scale;
    
    NSDecimalNumber *number = [[[NSDecimalNumber alloc] initWithDouble:[self doubleValue]] decimalNumberByRoundingAccordingToBehavior:[self roundBankersWithScale:scale]];
    
    return [formatter stringFromNumber:number];
}

- (NSDecimalNumberHandler *)roundBankersWithScale:(NSInteger)scale{
    return [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
}

@end
