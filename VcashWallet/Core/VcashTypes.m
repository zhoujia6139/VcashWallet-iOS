//
//  VcashTypes.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashTypes.h"

@implementation Input
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = [PublicTool getDataFromArray:dic[@"commit"]];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Plain"]){
        self.features = OutputFeaturePlain;
    }
    else if ([fea isEqualToString:@"Coinbase"]){
        self.features = OutputFeatureCoinbase;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (self.commit){
        dic[@"commit"] = [PublicTool getArrFromData:self.commit];
    }
    
    if (self.features == OutputFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == OutputFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    
    return YES;
}

@end

@implementation Output
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = [PublicTool getDataFromArray:dic[@"commit"]];
    self.proof = [PublicTool getDataFromArray:dic[@"proof"]];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Plain"]){
        self.features = OutputFeaturePlain;
    }
    else if ([fea isEqualToString:@"Coinbase"]){
        self.features = OutputFeatureCoinbase;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (self.commit){
        dic[@"commit"] = [PublicTool getArrFromData:self.commit];
    }
    if (self.proof){
        dic[@"proof"] = [PublicTool getArrFromData:self.proof];
    }
    
    if (self.features == OutputFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == OutputFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    
    return YES;
}

@end

@implementation TxKernel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.excess = [PublicTool getDataFromArray:dic[@"excess"]];
    self.excess_sig = [PublicTool getDataFromArray:dic[@"excess_sig"]];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Plain"]){
        self.features = KernelFeaturePlain;
    }
    else if ([fea isEqualToString:@"Coinbase"]){
        self.features = KernelFeatureCoinbase;
    }
    else if ([fea isEqualToString:@"HeightLocked"]){
        self.features = KernelFeatureHeightLocked;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (self.excess){
        dic[@"excess"] = [PublicTool getArrFromData:self.excess];
    }
    if (self.excess_sig){
        dic[@"excess_sig"] = [PublicTool getArrFromData:self.excess_sig];
    }
    
    if (self.features == KernelFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == KernelFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    else if (self.features == KernelFeatureHeightLocked){
        dic[@"features"] = @"HeightLocked";
    }
    return YES;
}

-(void)setLock_height:(uint64_t)lock_height{
    _lock_height = lock_height;
    _features = [VcashTransaction featureWithLockHeight:lock_height];
}


@end

@implementation TransactionBody

-(id)init{
    self = [super init];
    if (self){
        _inputs = [NSMutableArray new];
        _outputs = [NSMutableArray new];
        _kernels = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"inputs" : [Input class],
             @"outputs" : [Output class],
             @"kernels" : [TxKernel class],
             };
}

@end

@implementation VcashTransaction
-(id)init{
    self = [super init];
    if (self){
        _body = [TransactionBody new];
    }
    return self;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.offset = [PublicTool getDataFromArray:dic[@"offset"]];
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (self.offset){
        dic[@"offset"] = [PublicTool getArrFromData:self.offset];
    }
    
    return YES;
}


+(KernelFeatures)featureWithLockHeight:(uint64_t)lock_height{
    return lock_height>0?KernelFeatureHeightLocked:KernelFeaturePlain;
}

+(NSData*)featureToData:(KernelFeatures)feature{
    uint8_t temp = feature;
    return [NSData dataWithBytes:&temp length:1];
}

@end

@implementation VcashProofInfo

@end


