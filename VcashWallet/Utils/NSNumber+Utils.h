//
//  NSNumber+Utils.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Utils)

@property (nonatomic, strong, readonly) NSString *p12fString;/*无格式，精确12位小数，补0， 四舍五入*/

@property (nonatomic, strong, readonly) NSString *p9fString;/*无格式，精确8位小数，不补0， 四舍五入*/

@property (nonatomic, strong, readonly) NSString *p09fString;/*无格式，精确8位小数，补0， 四舍五入*/

@property (nonatomic, strong, readonly) NSString *p3fString;/*无格式，精确3位小数，不补0， 四舍五入*/

@property (nonatomic, strong, readonly) NSString *p06fString;/*无格式，精确3位小数，补0， 四舍五入*/

@property (nonatomic, strong, readonly) NSString *p02fString;/*无格式，精确两位小数，补0*/

@property (nonatomic, strong, readonly) NSString *p0fString;/*无格式*/

@property (nonatomic, strong, readonly) NSString *scientificNotationString;/*科学计数转换成字符串*/

- (NSString *)roundCeilingStringWithScale:(NSInteger)scale;


@end
