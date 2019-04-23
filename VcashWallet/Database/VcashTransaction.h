//
//  VcashTransaction.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

@end

@interface Output : NSObject

@property (assign, nonatomic)OutputFeatures features;

@property (strong, nonatomic)NSData* commit;

@property (strong, nonatomic)NSData* proof;

@end

@interface TxKernel : NSObject

@property (assign, nonatomic)KernelFeatures features;

@property (assign, nonatomic)uint64_t fee;

@property (assign, nonatomic)uint64_t lock_height;

@property (strong, nonatomic)NSData* excess;

@property (strong, nonatomic)NSData* excess_sig;

@end

@interface TransactionBody : NSObject

@property (strong, nonatomic)NSMutableArray<Input*>* inputs;

@property (strong, nonatomic)NSMutableArray<Output*>* outputs;

@property (strong, nonatomic)NSMutableArray<TxKernel*>* kernels;

@end


@interface VcashTransaction : NSObject

@property (strong, nonatomic)NSData* offset;

@property (strong, nonatomic)TransactionBody* body;

@end


NS_ASSUME_NONNULL_END
