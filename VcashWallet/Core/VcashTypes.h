//
//  VcashTypes.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashOutput.h"
#import "VcashSlate.h"

NS_ASSUME_NONNULL_BEGIN

#define VCASH_BASE 1000000000

#define SECRET_KEY_SIZE 32

#define PEDERSEN_COMMITMENT_SIZE 33

#define PEDERSEN_COMMITMENT_SIZE_INTERNAL 64


@class VcashSecretKey, VcashSignature;

typedef enum{
    OutputFeaturePlain = 0,
    OutputFeatureCoinbase = 1,
}OutputFeatures;

typedef enum{
    KernelFeaturePlain = 0,
    KernelFeatureCoinbase = 1,
    KernelFeatureHeightLocked = 2,
}KernelFeatures;

@interface Input : NSObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSData* commit;

-(NSData*)computePayload;

@end

@interface Output : NSObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSData* commit;

@property (strong, nonatomic)NSData* proof;

-(NSData*)computePayload;

@end

@interface TxKernel : NSObject

@property (assign, nonatomic)KernelFeatures features;

@property (assign, nonatomic)uint64_t fee;

@property (assign, nonatomic)uint64_t lock_height;

@property (strong, nonatomic)NSData* excess;

@property (strong, nonatomic)VcashSignature* excess_sig;

+(KernelFeatures)featureWithLockHeight:(uint64_t)lock_height;

-(NSData*)kernelMsgToSign;

-(BOOL)verify;

-(NSData*)computePayload;

@end

@interface TransactionBody : NSObject

@property (strong, nonatomic)NSMutableArray<Input*>* inputs;

@property (strong, nonatomic)NSMutableArray<Output*>* outputs;

@property (strong, nonatomic)NSMutableArray<TxKernel*>* kernels;

-(NSData*)computePayload;

@end


@interface VcashTransaction : NSObject

@property (strong, nonatomic)NSData* offset;

@property (strong, nonatomic)TransactionBody* body;

-(NSData*)calculateFinalExcess;

-(BOOL)setTxExcess:(NSData*)excess andTxSig:(VcashSignature*)sig;

-(NSData*)computePayload;


@end

@interface VcashProofInfo : NSObject

@property(assign, nonatomic)BOOL isSuc;

@property(assign, nonatomic)uint64_t value;

@property(strong, nonatomic)VcashSecretKey* secretKey;

@property(strong, nonatomic)NSData* message;

@end

@interface VcashSignature : NSObject

+(instancetype)zeroSignature;

@property(strong, nonatomic)NSData* sig_data;

-(instancetype)initWithCompactData:(NSData*)compactData;

-(instancetype)initWithData:(NSData*)sigData;

-(NSData*)getCompactData;

@end



NS_ASSUME_NONNULL_END
