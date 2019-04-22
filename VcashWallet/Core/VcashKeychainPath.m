//
//  VcashKeychainPath.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashKeychainPath.h"

@implementation VcashKeychainPath
{
    uint8_t _depth;
    uint32_t _path[4];
}


- (id) initWithDepth:(uint8_t)depth andPathData:(NSData*)pathdata{
    if (self = [super init]) {
        _depth = depth;
        if (pathdata.length == 16){
            _path[0] = OSReadBigInt32(pathdata.bytes, 0);
            _path[1] = OSReadBigInt32(pathdata.bytes, 4);
            _path[2] = OSReadBigInt32(pathdata.bytes, 8);
            _path[3] = OSReadBigInt32(pathdata.bytes, 12);
        }
        else{
            return nil;
        }
    }
    return self;
}

- (id) initWithDepth:(uint8_t)depth d0:(uint32_t)d0 d1:(uint32_t)d1 d2:(uint32_t)d2 d3:(uint32_t)d3{
    if (self = [super init]) {
        _depth = depth;
        _path[0] = d0;
        _path[1] = d1;
        _path[2] = d2;
        _path[3] = d3;
    }
    return self;
}

- (id) initWithPathstr:(NSString*)pathStr{
    if (self = [super init]) {
        if (![self parsePathStr:pathStr]){
            return nil;
        }
    }
    return self;
}

-(NSString*)pathStr{
    NSMutableString* path = [[NSMutableString alloc] initWithString:@""];
    for (uint8_t i=0; i<_depth; i++){
        [path appendFormat:@"/%d", _path[i]];
    }
    
    return path;
}

-(NSData*)pathData{
    uint8_t pathinfo[16];
    OSWriteBigInt32(pathinfo, 0, _path[0]);
    OSWriteBigInt32(pathinfo, 4, _path[1]);
    OSWriteBigInt32(pathinfo, 8, _path[2]);
    OSWriteBigInt32(pathinfo, 12, _path[3]);
    return [NSData dataWithBytes:pathinfo length:16];
}

-(BOOL)parsePathStr:(NSString*)pathStr{
    NSArray<NSString*>* arr = [pathStr componentsSeparatedByString:@"/"];
    _depth = [arr count];
    if (_depth > 4){
        return NO;
    }
    for (NSUInteger i=0; i<_depth; i++){
        _path[i] = [[arr objectAtIndex:i] unsignedIntValue];
    }
    return YES;
}

@end
