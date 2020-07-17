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
    OutputFeatureTokenIssue = 98,
    OutputFeatureToken = 99,
}OutputFeatures;

typedef enum{
    KernelFeaturePlain = 0,
    KernelFeatureCoinbase = 1,
    KernelFeatureHeightLocked = 2,
    KernelFeatureNoRecentDuplicate = 3,
}KernelFeatures;

typedef enum{
    KernelFeaturePlainToken = 0,
    KernelFeatureIssueToken = 1,
    KernelFeatureHeightLockedToken = 2,
}TokenKernelFeatures;

@interface TxBaseObject:NSObject

-(NSData*)computePayloadForHash:(BOOL)yesOrNo;

-(NSData*)blake2bHash;

@end

@interface Input : TxBaseObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSData* commit;

@end

@interface TokenInput : TxBaseObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSString* token_type;

@property (strong, nonatomic)NSData* commit;

@end

@interface Output : TxBaseObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSData* commit;

@property (strong, nonatomic)NSData* proof;

@end

@interface TokenOutput : TxBaseObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSString* token_type;

@property (strong, nonatomic)NSData* commit;

@property (strong, nonatomic)NSData* proof;

@end

@interface TxKernel : TxBaseObject

@property (assign, nonatomic)KernelFeatures features;

@property (assign, nonatomic)uint64_t fee;

@property (assign, nonatomic)uint64_t lock_height;

@property (strong, nonatomic)NSData* excess;

@property (strong, nonatomic)VcashSignature* excess_sig;

+(KernelFeatures)featureWithLockHeight:(uint64_t)lock_height;

-(NSData*)kernelMsgToSign;

-(BOOL)verify;

@end

@interface TokenTxKernel : TxBaseObject

@property (assign, nonatomic)TokenKernelFeatures features;

@property (strong, nonatomic)NSString* token_type;

@property (assign, nonatomic)uint64_t lock_height;

@property (strong, nonatomic)NSData* excess;

@property (strong, nonatomic)VcashSignature* excess_sig;

+(TokenKernelFeatures)featureWithLockHeight:(uint64_t)lock_height;

-(NSData*)kernelMsgToSign;

-(BOOL)verify;

@end

@interface TransactionBody : TxBaseObject

@property (strong, nonatomic)NSMutableArray<Input*>* inputs;

@property (strong, nonatomic)NSMutableArray<TokenInput*>* token_inputs;

@property (strong, nonatomic)NSMutableArray<Output*>* outputs;

@property (strong, nonatomic)NSMutableArray<TokenOutput*>* token_outputs;

@property (strong, nonatomic)NSMutableArray<TxKernel*>* kernels;

@property (strong, nonatomic)NSMutableArray<TokenTxKernel*>* token_kernels;

@end


@interface VcashTransaction : TxBaseObject

@property (strong, nonatomic)NSData* offset;

@property (strong, nonatomic)TransactionBody* body;

-(NSData*)calculateFinalExcess;

//-(NSData*)calculateTokenFinalExcess;

-(BOOL)setTxExcess:(NSData*)excess andTxSig:(VcashSignature*)sig;

-(BOOL)setTokenTxExcess:(NSData*)excess andTxSig:(VcashSignature*)sig;

-(void)sortTx;


@end

@interface VcashProofInfo : NSObject

@property(assign, nonatomic)BOOL isSuc;

@property(assign, nonatomic)uint8_t version;

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

@interface ExportPaymentInfo : NSObject

@property(strong, nonatomic)NSString* token_type;

@property(strong, nonatomic)NSString* amount;

@property(strong, nonatomic)NSString* excess;

@property(strong, nonatomic)NSString* recipient_address;

@property(strong, nonatomic)NSString* recipient_sig;

@property(strong, nonatomic)NSString* sender_address;

@property(strong, nonatomic)NSString* sender_sig;

@end


NS_ASSUME_NONNULL_END
