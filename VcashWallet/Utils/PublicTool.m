//
//  PublicTool.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/24.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "PublicTool.h"

@implementation PublicTool

+(NSData*)getDataFromArray:(NSArray*)array{
    if (!array){
        return nil;
    }
    NSMutableData* retData= [NSMutableData new];
    for (NSNumber* item in array){
        unsigned char bit = [item unsignedCharValue];
        [retData appendBytes:&bit length:1];
    }
    
    return retData;
}

+(NSArray*)getArrFromData:(NSData*)data{
    if (!data){
        return nil;
    }
    NSMutableArray* arr = [NSMutableArray new];
    unsigned char* bits = (unsigned char*)data.bytes;
    for (NSUInteger i=0; i<data.length; i++){
        NSNumber* number = [NSNumber numberWithUnsignedChar:bits[i]];
        [arr addObject:number];
    }
    return arr;
}

@end
