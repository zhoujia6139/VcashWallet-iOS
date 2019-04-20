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

- (id) initWithDepth:(unsigned char)depth andPathData:(NSData*)pathdata{
    assert(pathdata.length == 16);
    if (self = [super init]) {
        _depth = depth;
        _path[0] = OSReadBigInt32(pathdata.bytes, 0);
        _path[1] = OSReadBigInt32(pathdata.bytes, 4);
        _path[2] = OSReadBigInt32(pathdata.bytes, 8);
        _path[3] = OSReadBigInt32(pathdata.bytes, 12);
    }
    return self;
}

-(NSString*)pathStr{
    NSMutableString* path = [[NSMutableString alloc] initWithString:@"/"];
    for (uint8_t i=0; i<_depth; i++){
        [path appendFormat:@"%d/", _path[i]];
    }
    
    return path;
}

@end
