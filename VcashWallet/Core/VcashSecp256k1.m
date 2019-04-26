//
//  VcashSecp256k1.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSecp256k1.h"
#include "secp256k1_bulletproofs.h"
#include "secp256k1_aggsig.h"
#import "CoreBitcoin.h"
#import "VcashSecretKey.h"

#define MAX_PROOF_SIZE 5134

#define BULLET_PROOF_MSG_SIZE 16

#define MAX_WIDTH (1 << 20)

#define SCRATCH_SPACE_SIZE (256 * MAX_WIDTH)



@implementation VcashSecp256k1
{
    secp256k1_context* _context;
    unsigned int _flag;
}

- (id) initWithFlag:(unsigned int)flags {
    if (self = [super init]) {
        _context = secp256k1_context_create(flags);
        _flag = flags;
    }
    return self;
}

-(NSData*)blindSwitch:(uint64_t)value withKey:(VcashSecretKey*)key {
    if (_flag == ContextCommit && key){
        uint8_t outdata[SECRET_KEY_SIZE];
        int ret = secp256k1_blind_switch(_context,
                               outdata,
                               key.data.bytes,
                               value,
                               &secp256k1_generator_const_h,
                               &secp256k1_generator_const_g,
                               [self getGeneratorJPub]);
        if (ret == 1){
            return [NSData dataWithBytes:outdata length:SECRET_KEY_SIZE];
        }
    }
    
    return nil;
}

-(BOOL)verifyEcSecretKey:(NSData*)data {
    if (data.length == SECRET_KEY_SIZE) {
        if (secp256k1_ec_seckey_verify(_context, data.bytes) == 1) {
            return YES;
        }
    }
    return NO;
}

-(NSData*)commitment:(uint64_t)value withKey:(VcashSecretKey*)key{
    if (_flag == ContextCommit && key){
        secp256k1_pedersen_commitment innerCommit;
        int ret = secp256k1_pedersen_commit(_context,
                                  &innerCommit,
                                  key.data.bytes,
                                  value,
                                  &secp256k1_generator_const_h,
                                  &secp256k1_generator_const_g);
        if (ret == 1){
            return [self serCommit:&innerCommit];
        }
    }
    
    return nil;
}

-(VcashSecretKey*)blindSumWithPositiveArr:(NSArray<NSData*>*)positive andNegative:(NSArray<NSData*>*)negative{
    uint8_t retData[32];
    NSUInteger totalCount = positive.count + negative.count;
    const uint8_t * point[totalCount];
    NSMutableArray* all = [[NSMutableArray alloc] initWithArray:positive];
    [all appendObjects:negative];
    for (NSUInteger i=0; i<all.count; i++){
        NSData* item = [all objectAtIndex:i];
        point[i] = item.bytes;
    }
    int ret = secp256k1_pedersen_blind_sum(_context,
                                           retData,
                                           point,
                                           totalCount,
                                           positive.count);
    if (ret == 1){
        return [[VcashSecretKey alloc] initWithData:[NSData dataWithBytes:retData length:32]];
    }
    else{
        return nil;
    }
}

-(NSData*)commitSumWithPositiveArr:(NSArray<NSData*>*)positive andNegative:(NSArray<NSData*>*)negative{
    secp256k1_pedersen_commitment innerCommit;
    secp256k1_pedersen_commitment* positiveVec[positive.count];
    secp256k1_pedersen_commitment* negativeVec[negative.count];
    for (NSUInteger i=0; i<positive.count; i++){
        NSData* item = [positive objectAtIndex:i];
        positiveVec[i] = (secp256k1_pedersen_commitment*)[self parseCommit:item].bytes;
    }
    for (NSUInteger i=0; i<negative.count; i++){
        NSData* item = [negative objectAtIndex:i];
        negativeVec[i] = (secp256k1_pedersen_commitment*)[self parseCommit:item].bytes;
    }
    int ret = secp256k1_pedersen_commit_sum(_context,
                                            &innerCommit,
                                            (void*)positiveVec,
                                            positive.count,
                                            (void*)negativeVec,
                                            negative.count);
    if (ret == 1){
        return [self serCommit:&innerCommit];
    }
    else{
        return nil;
    }
}

-(NSData*)commitToPubkey:(NSData*)commitment{
    secp256k1_pubkey pubkey;
    NSData* internalCommit = [self parseCommit:commitment];
    if (internalCommit){
        int ret = secp256k1_pedersen_commitment_to_pubkey(_context,
                                                          &pubkey,
                                                         (secp256k1_pedersen_commitment*)internalCommit.bytes);
        if (ret == 1){
            return [[NSData alloc] initWithBytes:pubkey.data length:64];
        }
    }
    return nil;
}

-(NSData*)getCompressedPubkey:(NSData*)pubkey{
    if (pubkey.length == 64){
        uint8_t compressKey[33];
        NSUInteger length = 33;
        int ret = secp256k1_ec_pubkey_serialize(_context,
                                                compressKey,
                                                &length,
                                                pubkey.bytes,
                                                SECP256K1_EC_COMPRESSED);
        if (ret == 1 && length == 33){
            return [[NSData alloc] initWithBytes:compressKey length:33];
        }
    }
    
    return nil;
}

-(NSData*)pubkeyFromCompressedKey:(NSData*)compressedkey{
    if (compressedkey.length == 33){
        secp256k1_pubkey pubkey;
        int ret = secp256k1_ec_pubkey_parse(_context,
                                            &pubkey,
                                            compressedkey.bytes,
                                            compressedkey.length);
        if (ret == 1){
            return [[NSData alloc] initWithBytes:pubkey.data length:64];
        }
    }

    return nil;
}

-(BOOL)verifySingleSignature:(NSData*)signature pubkey:(NSData*)pubkey nonceSum:(nullable NSData*)nonce_sum pubkeySum:(NSData*)pubkey_sum andMsgData:(NSData*)msg{
    int ret = secp256k1_aggsig_verify_single(_context,
                                             signature.bytes,
                                             msg.bytes,
                                             nonce_sum.bytes,
                                             pubkey.bytes,
                                             pubkey_sum.bytes,
                                             nil,
                                             true);
    
    return (ret == 1);
}

-(NSData*)calculateSingleSignature:(NSData*)sec_key secNonce:(NSData*)sec_nonce nonceSum:(NSData*)nonce_sum pubkeySum:(NSData*)pubkey_sum andMsgData:(NSData*)msg{
    NSData* seed = BTCRandomDataWithLength(32);
    uint8_t retSig[64];
    int ret = secp256k1_aggsig_sign_single(_context,
                                 retSig,
                                 msg.bytes,
                                 sec_key.bytes,
                                 sec_nonce.bytes,
                                 nil,
                                 nonce_sum.bytes,
                                 nonce_sum.bytes,
                                 pubkey_sum.bytes,
                                 seed.bytes);
    if (ret == 1){
        return [[NSData alloc] initWithBytes:retSig length:64];
    }
    else{
        return nil;
    }
}

-(NSData*)combinationPubkey:(NSArray*)arr{
    secp256k1_pubkey* inkeyArr[arr.count];
    for (NSUInteger i=0; i<arr.count; i++){
        NSData* item = [arr objectAtIndex:i];
        inkeyArr[i] = (secp256k1_pubkey*)item.bytes;
    }
    secp256k1_pubkey outKey;
    int ret = secp256k1_ec_pubkey_combine(_context,
                                &outKey,
                                (void*)inkeyArr,
                                arr.count);
    if (ret == 1){
        return [[NSData alloc] initWithBytes:outKey.data length:64];
    }
    else{
        return nil;
    }
}

-(NSData*)combinationSignature:(NSArray*)sigArr nonceSum:(NSData*)nonceSum{
    uint8_t* sigs[sigArr.count];
    for (NSUInteger i=0; i<sigArr.count; i++){
        NSData* item = [sigArr objectAtIndex:i];
        sigs[i] = (uint8_t*)item.bytes;
    }
    uint8_t retSig[64];
    int ret = secp256k1_aggsig_add_signatures_single(_context,
                                                     retSig,
                                                     (void*)sigs,
                                                     sigArr.count,
                                                     nonceSum.bytes);
    if (ret == 1){
        return [[NSData alloc] initWithBytes:retSig length:64];
    }
    else{
        return nil;
    }
}

//secret nonce
-(VcashSecretKey*)exportSecnonceSingle{
    NSData* seed = BTCRandomDataWithLength(32);
    uint8_t retData[32];
    int ret = secp256k1_aggsig_export_secnonce_single(_context,
                                                      retData,
                                                      seed.bytes);
    if (ret == 1){
        return [[VcashSecretKey alloc] initWithData:[NSData dataWithBytes:retData length:32]];
    }
    else{
        return nil;
    }
}

-(NSData*)getPubkeyFormSecretKey:(VcashSecretKey*)key{
    secp256k1_pubkey pubkey;
    int ret = secp256k1_ec_pubkey_create(_context,
                               &pubkey,
                               key.data.bytes);
    if (ret == 1){
        return [NSData dataWithBytes:pubkey.data length:64];
    }
    else{
        return nil;
    }
                               
}

#pragma proof
-(NSData*)createBulletProof:(uint64_t)value key:(VcashSecretKey*)key nounce:(VcashSecretKey*)nounce andMessage:(NSData*)message{
    uint8_t proof[MAX_PROOF_SIZE];
    size_t proofSize = MAX_PROOF_SIZE;
    
    const unsigned char* key_point = key.data.bytes;
    const unsigned char* const* key_points = &key_point;
    //const unsigned char* const* temp = &((const unsigned char*)key.data.bytes);
    
    secp256k1_scratch_space* scratch = secp256k1_scratch_space_create(_context, SCRATCH_SPACE_SIZE);
    int ret = secp256k1_bulletproof_rangeproof_prove(_context,
                                           scratch,
                                           [self sharedGenerators],
                                           proof,
                                           &proofSize,
                                           nil,
                                           nil,
                                           nil,
                                           &value,
                                           nil,
                                           key_points,
                                           nil,
                                           1,
                                           &secp256k1_generator_const_h,
                                           64,
                                           nounce.data.bytes,
                                           nil,
                                           nil,
                                           0,
                                           message.bytes);
    secp256k1_scratch_space_destroy(scratch);
    if (ret == 1){
        return [NSData dataWithBytes:proof length:proofSize];
    }
    else{
        return nil;
    }
}

-(BOOL)verifyBulletProof:(NSData*)commitment withProof:(NSData*)proof{
    secp256k1_scratch_space* scratch = secp256k1_scratch_space_create(_context, SCRATCH_SPACE_SIZE);
    int ret = secp256k1_bulletproof_rangeproof_verify(_context,
                                            scratch,
                                            [self sharedGenerators],
                                            proof.bytes,
                                            proof.length,
                                            nil,
                                            [self parseCommit:commitment].bytes,
                                            1,
                                            64,
                                            &secp256k1_generator_const_h,
                                            nil,
                                            0);
    secp256k1_scratch_space_destroy(scratch);
    
    return (ret == 1);
}

-(VcashProofInfo*)rewindBulletProof:(NSData*)commitment nounce:(VcashSecretKey*)nounce withProof:(NSData*)proof{
    uint8_t blindOut[SECRET_KEY_SIZE];
    uint64_t value = 0;
    uint8_t messageOut[BULLET_PROOF_MSG_SIZE];
    
    //secp256k1_scratch_space* scratch = secp256k1_scratch_space_create(_context, SCRATCH_SPACE_SIZE);
    int ret = secp256k1_bulletproof_rangeproof_rewind(_context,
                                            [self sharedGenerators],
                                            &value,
                                            blindOut,
                                            proof.bytes,
                                            proof.length,
                                            0,
                                            [self parseCommit:commitment].bytes,
                                            &secp256k1_generator_const_h,
                                            nounce.data.bytes,
                                            nil,
                                            0,
                                            messageOut);
    //secp256k1_scratch_space_destroy(scratch);
    if (ret == 1){
        VcashProofInfo* info = [VcashProofInfo new];
        info.isSuc = YES;
        info.value = value;
        info.secretKey = [[VcashSecretKey alloc] initWithData:[NSData dataWithBytes:blindOut length:SECRET_KEY_SIZE]];
        info.message = [NSData dataWithBytes:messageOut length:BULLET_PROOF_MSG_SIZE];
        return info;
    }
    else{
        return nil;
    }
}


#pragma private method

-(secp256k1_bulletproof_generators *)sharedGenerators{
    static secp256k1_bulletproof_generators * proofGen = NULL;
    if (proofGen == NULL) {
        proofGen = secp256k1_bulletproof_generators_create(_context, &secp256k1_generator_const_g, 256);
    }
    
    return proofGen;
}

-(NSData*)parseCommit:(NSData*)commitment{
    secp256k1_pedersen_commitment innerCommit;
    int ret = secp256k1_pedersen_commitment_parse(_context,
                                            &innerCommit,
                                            commitment.bytes);
    if (ret == 1){
        return [NSData dataWithBytes:innerCommit.data length:PEDERSEN_COMMITMENT_SIZE_INTERNAL];
    }
    else{
        return nil;
    }
}

-(NSData*)serCommit:(secp256k1_pedersen_commitment*)innercommitment{
    uint8_t outCommit[PEDERSEN_COMMITMENT_SIZE];
    secp256k1_pedersen_commitment_serialize(_context,
                                            outCommit,
                                            innercommitment);
    return [NSData dataWithBytes:outCommit length:PEDERSEN_COMMITMENT_SIZE];
}

-(secp256k1_pubkey*)getGeneratorJPub{
    static secp256k1_pubkey GENERATOR_J_PUB = {{
        0x5f, 0x15, 0x21, 0x36, 0x93, 0x93, 0x01, 0x2a,
        0x8d, 0x8b, 0x39, 0x7e, 0x9b, 0xf4, 0x54, 0x29,
        0x2f, 0x5a, 0x1b, 0x3d, 0x38, 0x85, 0x16, 0xc2,
        0xf3, 0x03, 0xfc, 0x95, 0x67, 0xf5, 0x60, 0xb8,
        0x3a, 0xc4, 0xc5, 0xa6, 0xdc, 0xa2, 0x01, 0x59,
        0xfc, 0x56, 0xcf, 0x74, 0x9a, 0xa6, 0xa5, 0x65,
        0x31, 0x6a, 0xa5, 0x03, 0x74, 0x42, 0x3f, 0x42,
        0x53, 0x8f, 0xaa, 0x2c, 0xd3, 0x09, 0x3f, 0xa4
    }};
    
    return &GENERATOR_J_PUB;
}

@end
