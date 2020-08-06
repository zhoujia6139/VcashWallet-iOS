//
//  VcashSlate.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSlate.h"
#import "VcashWallet.h"
#import "VcashKeychainPath.h"
#import "VcashContext.h"
#import "VcashSecp256k1.h"
#import "VcashTypes.h"
#import "payment-proof-lib.h"

@implementation VcashSlate

-(id)init{
    self = [super init];
    if (self){
        const char* uuid_cstr = create_random_uuid();
        _uuid = [NSString stringWithCString:uuid_cstr encoding:NSUTF8StringEncoding];
        c_str_free(uuid_cstr);
        _version_info = [VersionCompatInfo createVersionInfo];
        _tx = [VcashTransaction new];
        _participant_data = [NSMutableArray new];
        _offset = [VcashSecretKey zeroKey].data;
        _num_participants = 2;
    }
    return self;
}

+(NSString*)getUUIDByData:(NSData*)data {
    const char* uuid_cstr = uuid_from_bytes(BTCHexFromData(data).UTF8String);
    NSString* uuid = [NSString stringWithCString:uuid_cstr encoding:NSUTF8StringEncoding];
    c_str_free(uuid_cstr);
    return uuid;
}

+(NSData*)getUUIDBytes:(NSString*)uuid {
    const char* bytes_str = bytes_from_uuid(uuid.UTF8String);
    NSString* hex_str = [NSString stringWithCString:bytes_str encoding:NSUTF8StringEncoding];
    c_str_free(bytes_str);
    
    return BTCDataFromHex(hex_str);
}

+(VcashSlate*)parseSlateFromData:(NSData*)binData {
    if (binData.length < 10) {
        return nil;
    }
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSUInteger location = 0;
    const void * data = binData.bytes;
    VcashSlate* slate = [VcashSlate new];

    slate.version_info = [VersionCompatInfo new];
    //version
    uint16_t version = OSReadBigInt16(data, location);
    location += 2;
    slate.version_info.version = version;
    
    //header version
    uint16_t header_version = OSReadBigInt16(data, location);
    location += 2;
    slate.version_info.block_header_version = header_version;
    
    //uuid
    NSData* uuidData = [binData subdataWithRange:NSMakeRange(location, 16)];
    location += 16;
    slate.uuid = [VcashSlate getUUIDByData:uuidData];
    
    //state
    uint8_t state;
    [binData getBytes:&state range:NSMakeRange(location, 1)];
    location += 1;
    slate.state = state;
    
    //offset
    NSData* offset = [binData subdataWithRange:NSMakeRange(location, 32)];
    location += 32;
    slate.offset = offset;
    
    //SlateOptFields
    uint8_t status;
    [binData getBytes:&status range:NSMakeRange(location, 1)];
    location += 1;
    if ((status & 0x01) > 0){
        uint8_t num_part;
        [binData getBytes:&num_part range:NSMakeRange(location, 1)];
        location += 1;
    }
    if ((status & 0x02) > 0){
        uint64_t amount = OSReadBigInt64(data, location);
        location += 8;
        slate.amount = amount;
    }
    if ((status & 0x04) > 0){
        uint64_t fee = OSReadBigInt64(data, location);
        location += 8;
        slate.fee = fee;
    }
    if ((status & 0x08) > 0){
        uint8_t kernel_features = 0;
        [binData getBytes:&kernel_features range:NSMakeRange(location, 1)];
        location += 1;
        slate.kernel_features = kernel_features;
    }
    if ((status & 0x10) > 0){
        uint64_t ttl = OSReadBigInt64(data, location);
        location += 8;
        slate.ttl_cutoff_height = ttl;
    }
    if ((status & 0x20) > 0){
        uint8_t token_kernel_features = 0;
        [binData getBytes:&token_kernel_features range:NSMakeRange(location, 1)];
        location += 1;
        slate.token_kernel_features = token_kernel_features;
    }
    
    //SigsWrapRef
    uint8_t pDatalen;
    [binData getBytes:&pDatalen range:NSMakeRange(location, 1)];
    location += 1;
    NSMutableArray* pDataArr = [NSMutableArray new];
    for (uint8_t i=0; i<pDatalen; i++) {
        ParticipantData* pData = [ParticipantData new];
        
        uint8_t has_partial;
        [binData getBytes:&has_partial range:NSMakeRange(location, 1)];
        location += 1;
        
        NSData* public_blind_excess = [binData subdataWithRange:NSMakeRange(location, 33)];
        location += 33;
        pData.public_blind_excess = [secp pubkeyFromCompressedKey:public_blind_excess];
        
        NSData* public_nonce = [binData subdataWithRange:NSMakeRange(location, 33)];
        location += 33;
        pData.public_nonce = [secp pubkeyFromCompressedKey:public_nonce];
        
        if (has_partial > 0) {
            NSData* sig_data = [binData subdataWithRange:NSMakeRange(location, 64)];
            location += 64;
            pData.part_sig = [[VcashSignature alloc] initWithData:sig_data];
        }
        
        [pDataArr addObject:pData];
    }
    slate.participant_data = pDataArr;
    
    //SlateOptStructsRef
    uint8_t struct_status;
    [binData getBytes:&struct_status range:NSMakeRange(location, 1)];
    location += 1;
    if ((struct_status & 0x01) > 0){
        uint16_t commit_len = OSReadBigInt16(data, location);
        location += 2;
        
        for (uint16_t i=0; i<commit_len; i++) {
            uint8_t has_proof;
            [binData getBytes:&has_proof range:NSMakeRange(location, 1)];
            location += 1;
            
            uint8_t features;
            [binData getBytes:&features range:NSMakeRange(location, 1)];
            location += 1;
            
            NSData* commit = [binData subdataWithRange:NSMakeRange(location, 33)];
            location += 33;
            
            if (has_proof > 0) {
                uint64_t proof_len = OSReadBigInt64(data, location);
                location += 8;
                
                NSData* proof = [binData subdataWithRange:NSMakeRange(location, proof_len)];
                location += proof_len;
                
                Output* output = [Output new];
                output.features = features;
                output.commit = commit;
                output.proof = proof;
                
                [slate.tx.body.outputs addObject:output];
            } else {
                Input* input = [Input new];
                input.features = features;
                input.commit = commit;
                
                [slate.tx.body.inputs addObject:input];
            }
        }
    }
    if ((struct_status & 0x02) > 0){
        PaymentInfo* paymentInfo = [PaymentInfo new];
        
        NSData* sender_address = [binData subdataWithRange:NSMakeRange(location, 32)];
        location += 32;
        paymentInfo.sender_address = BTCHexFromData(sender_address);
        
        NSData* receiver_address = [binData subdataWithRange:NSMakeRange(location, 32)];
        location += 32;
        paymentInfo.receiver_address = BTCHexFromData(receiver_address);
        
        uint8_t has_sig;
        [binData getBytes:&has_sig range:NSMakeRange(location, 1)];
        location += 1;
        if (has_sig > 0) {
            NSData* signature = [binData subdataWithRange:NSMakeRange(location, 64)];
            location += 64;
            paymentInfo.receiver_signature = BTCHexFromData(signature);
        }
        slate.payment_proof = paymentInfo;
    }
    if ((struct_status & 0x04) > 0){
        NSData* token_type_data = [binData subdataWithRange:NSMakeRange(location, 32)];
        location += 32;
        slate.token_type = BTCHexFromData(token_type_data);
    }
    if ((struct_status & 0x08) > 0){
        uint16_t commit_len = OSReadBigInt16(data, location);
        location += 2;
        
        for (uint16_t i=0; i<commit_len; i++) {
            uint8_t has_proof;
            [binData getBytes:&has_proof range:NSMakeRange(location, 1)];
            location += 1;
            
            NSData* token_type = [binData subdataWithRange:NSMakeRange(location, 32)];
            location += 32;
            
            uint8_t features;
            [binData getBytes:&features range:NSMakeRange(location, 1)];
            location += 1;
            
            NSData* commit = [binData subdataWithRange:NSMakeRange(location, 33)];
            location += 33;
            
            if (has_proof > 0) {
                uint64_t proof_len = OSReadBigInt64(data, location);
                location += 8;
                
                NSData* proof = [binData subdataWithRange:NSMakeRange(location, proof_len)];
                location += proof_len;
                
                TokenOutput* output = [TokenOutput new];
                output.token_type = BTCHexFromData(token_type);
                output.features = features;
                output.commit = commit;
                output.proof = proof;
                
                [slate.tx.body.token_outputs addObject:output];
            } else {
                TokenInput* input = [TokenInput new];
                input.token_type = BTCHexFromData(token_type);
                input.features = features;
                input.commit = commit;
                
                [slate.tx.body.token_inputs addObject:input];
            }
        }
    }
    
    //feat
    if (slate.kernel_features == 2){
        uint64_t lock_height = OSReadBigInt64(data, location);
        location += 8;
        slate.kernel_features_args = [KernelFeaturesArgs new];
        slate.kernel_features_args.lock_height = lock_height;
    }
    
    //token_feat
    if (slate.token_kernel_features == 2){
        uint64_t token_lock_height = OSReadBigInt64(data, location);
        location += 8;
        slate.token_kernel_features_args = [KernelFeaturesArgs new];
        slate.token_kernel_features_args.lock_height = token_lock_height;
    }
    
    return slate;
}

-(NSData*)selializeAsData{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSMutableData* data = [NSMutableData new];
    //version
    {
        uint8_t buf[2];
        OSWriteBigInt16(buf, 0, self.version_info.version);
        [data appendBytes:buf length:2];
    }
    //header version
    {
        uint8_t buf[2];
        OSWriteBigInt16(buf, 0, self.version_info.block_header_version);
        [data appendBytes:buf length:2];
    }
    
    //uuid
    NSData* uuidData = [VcashSlate getUUIDBytes:self.uuid];
    [data appendData:uuidData];
    
    //state
    uint8_t state = self.state;
    [data appendBytes:&state length:1];
    
    //offset
    [data appendData:self.offset];
    
    //SlateOptFields
    uint8_t status = 0;
    if (self.num_participants != 2) {
        status |= 0x01;
    }
    if (self.amount > 0) {
        status |= 0x02;
    }
    if (self.fee > 0) {
        status |= 0x04;
    }
    if (self.kernel_features > 0) {
        status |= 0x08;
    }
    if (self.ttl_cutoff_height > 0) {
        status |= 0x10;
    }
    if (self.token_kernel_features > 0) {
        status |= 0x20;
    }
    [data appendBytes:&status length:1];
    if (self.num_participants != 2) {
        uint8_t num = self.num_participants;
        [data appendBytes:&num length:1];
    }
    if (self.amount > 0) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.amount);
        [data appendBytes:buf length:8];
    }
    if (self.fee > 0) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.fee);
        [data appendBytes:buf length:8];
    }
    if (self.kernel_features > 0) {
        uint8_t num = self.kernel_features;
        [data appendBytes:&num length:1];
    }
    if (self.ttl_cutoff_height > 0) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.ttl_cutoff_height);
        [data appendBytes:buf length:8];
    }
    if (self.token_kernel_features > 0) {
        uint8_t num = self.token_kernel_features;
        [data appendBytes:&num length:1];
    }
    
    //SigsWrapRef
    uint8_t participantDataLen = self.participant_data.count;
    [data appendBytes:&participantDataLen length:1];
    for (ParticipantData* pData in self.participant_data) {
        uint8_t has_sig = 0;
        if (pData.part_sig != NULL) {
            has_sig = 1;
        }
        [data appendBytes:&has_sig length:1];
        
        [data appendData:[secp getCompressedPubkey:pData.public_blind_excess]];
        [data appendData:[secp getCompressedPubkey:pData.public_nonce]];
        if (pData.part_sig != NULL){
            [data appendData:pData.part_sig.sig_data];
        }
    }
    
    //SlateOptStructsRef
    uint8_t struct_status = 0;
    {
        //coms
        struct_status |= 0x01;
//        NSUInteger commitCount = self.tx.body.inputs.count + self.tx.body.outputs.count;
//        if (commitCount > 0){
//            struct_status |= 0x01;
//        }
        
        //proof
        if (self.payment_proof != NULL) {
            struct_status |= 0x02;
        }
        //token_type
        if (self.token_type != NULL) {
            struct_status |= 0x04;
        }
        
        //token coms
        struct_status |= 0x08;
//        NSUInteger tokenCommitCount = self.tx.body.token_inputs.count + self.tx.body.token_outputs.count;
//        if (tokenCommitCount > 0){
//            struct_status |= 0x08;
//        }
    }
    [data appendBytes:&struct_status length:1];
    {
        //coms
        {
            NSUInteger commitCount = self.tx.body.inputs.count + self.tx.body.outputs.count;
            uint8_t buf[2];
            OSWriteBigInt16(buf, 0, commitCount);
            [data appendBytes:buf length:2];
            
            for (Input* input in self.tx.body.inputs) {
                uint8_t hasProof = 0;
                [data appendBytes:&hasProof length:1];
                
                uint8_t feature = input.features;
                [data appendBytes:&feature length:1];
                
                [data appendData:input.commit];
            }
            
            for (Output* output in self.tx.body.outputs) {
                uint8_t hasProof = 1;
                [data appendBytes:&hasProof length:1];
                
                uint8_t feature = output.features;
                [data appendBytes:&feature length:1];
                
                [data appendData:output.commit];
                
                uint64_t proof_length = output.proof.length;
                uint8_t buf[8];
                OSWriteBigInt64(buf, 0, proof_length);
                [data appendBytes:buf length:8];
                
                [data appendData:output.proof];
            }
        }

        
        //proof
        if (self.payment_proof != NULL) {
            NSData* senderData = BTCDataFromHex(self.payment_proof.sender_address);
            [data appendData:senderData];
            NSData* receiverData = BTCDataFromHex(self.payment_proof.receiver_address);
            [data appendData:receiverData];
            if (self.payment_proof.receiver_signature != NULL) {
                uint8_t tmp_byte = 1;
                [data appendBytes:&tmp_byte length:1];
                NSData* sigData = BTCDataFromHex(self.payment_proof.receiver_signature);
                [data appendData:sigData];
            } else {
                uint8_t tmp_byte = 0;
                [data appendBytes:&tmp_byte length:1];
            }
        }

        //token type
        if (self.token_type != NULL) {
            [data appendData:BTCDataFromHex(self.token_type)];
        }
        
        //token coms
        {
            NSUInteger commitCount = self.tx.body.token_inputs.count + self.tx.body.token_outputs.count;
            uint8_t buf[2];
            OSWriteBigInt16(buf, 0, commitCount);
            [data appendBytes:buf length:2];
            
            for (TokenInput* input in self.tx.body.token_inputs) {
                uint8_t hasProof = 0;
                [data appendBytes:&hasProof length:1];
                
                [data appendData:BTCDataFromHex(input.token_type)];
                
                uint8_t feature = input.features;
                [data appendBytes:&feature length:1];
                
                [data appendData:input.commit];
            }
            
            for (TokenOutput* output in self.tx.body.token_outputs) {
                uint8_t hasProof = 1;
                [data appendBytes:&hasProof length:1];
                
                [data appendData:BTCDataFromHex(output.token_type)];
                
                uint8_t feature = output.features;
                [data appendBytes:&feature length:1];
                
                [data appendData:output.commit];
                
                uint64_t proof_length = output.proof.length;
                uint8_t buf[8];
                OSWriteBigInt64(buf, 0, proof_length);
                [data appendBytes:buf length:8];
                
                [data appendData:output.proof];
            }
        }
    }
    
    //feat
    if (self.kernel_features == 2) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.kernel_features_args.lock_height);
        [data appendBytes:buf length:8];
    }
    
    //token_feat
    if (self.token_kernel_features == 2) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.token_kernel_features_args.lock_height);
        [data appendBytes:buf length:8];
    }
    
    return data;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)ret_dic {
    [ret_dic removeAllObjects];
    
    ret_dic[@"ver"] = @"4:3";
    
    ret_dic[@"id"] = self.uuid;
    
    NSString* state;
    switch (self.state) {
        case Unknown:
            state = @"NA";
            break;
        case Standard1:
            state = @"S1";
            break;
        case Standard2:
            state = @"S2";
            break;
        case Standard3:
            state = @"S3";
            break;
        case Invoice1:
            state = @"I1";
            break;
        case Invoice2:
            state = @"I2";
            break;
        case Invoice3:
            state = @"I3";
            break;
            
        default:
            break;
    }
    ret_dic[@"sta"] = state;
    
    ret_dic[@"off"] = BTCHexFromData(self.offset);
    
    if (self.num_participants != 2){
        ret_dic[@"num_parts"] = @(self.num_participants);
    }
    
    if (self.amount != 0){
        ret_dic[@"amt"] = @(self.amount);
    }
    
    if (self.token_type != NULL) {
        ret_dic[@"token_type"] = self.token_type;
    }
    
    if (self.fee != 0){
        ret_dic[@"fee"] = @(self.fee);
    }
    
    if (self.kernel_features != 0){
        ret_dic[@"feat"] = @(self.kernel_features);
    }
    
    if (self.token_kernel_features != 0){
        ret_dic[@"token_feat"] = @(self.token_kernel_features);
    }
    
    if (self.ttl_cutoff_height != 0) {
        ret_dic[@"ttl"] = @(self.ttl_cutoff_height);
    }
    
    if (self.participant_data.count > 0) {
        NSMutableArray* arr = [NSMutableArray new];
        for (ParticipantData* data in self.participant_data) {
            NSMutableDictionary* dic = [NSMutableDictionary new];
            
            VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
            
            if (data.public_blind_excess){
                NSData* compressed = [secp getCompressedPubkey:data.public_blind_excess];
                dic[@"xs"] = BTCHexFromData(compressed);
            }

            if (data.public_nonce){
                NSData* noncecompressed = [secp getCompressedPubkey:data.public_nonce];
                dic[@"nonce"] = BTCHexFromData(noncecompressed);
            }
            
            if (data.part_sig) {
                NSData* compactPartSig = [data.part_sig getCompactData];
                dic[@"part"] = BTCHexFromData(compactPartSig);
            }
            
            [arr addObject:dic];
        }
        
        ret_dic[@"sigs"] = arr;
    }
    
    NSUInteger commitCount = self.tx.body.inputs.count + self.tx.body.outputs.count;
    if (commitCount > 0) {
        NSMutableArray* arr = [NSMutableArray new];
        
        for (Input* input in self.tx.body.inputs) {
            NSMutableDictionary* dic = [NSMutableDictionary new];
            [dic setValue:BTCHexFromData(input.commit) forKey:@"c"];
            if (input.features != OutputFeaturePlain) {
                [dic setValue:@(input.features) forKey:@"f"];
            }
            [arr addObject:dic];
        }
        
        for (Output* output in self.tx.body.outputs) {
            NSMutableDictionary* dic = [NSMutableDictionary new];
            [dic setValue:BTCHexFromData(output.commit) forKey:@"c"];
            [dic setValue:BTCHexFromData(output.proof) forKey:@"p"];
            if (output.features != OutputFeaturePlain) {
                [dic setValue:@(output.features) forKey:@"f"];
            }
            [arr addObject:dic];
        }
        
        ret_dic[@"coms"] = arr;
    }
    
    NSUInteger tokenCommitCount = self.tx.body.token_inputs.count + self.tx.body.token_outputs.count;
    if (tokenCommitCount > 0) {
        NSMutableArray* arr = [NSMutableArray new];
        
        for (TokenInput* input in self.tx.body.token_inputs) {
            NSMutableDictionary* dic = [NSMutableDictionary new];
            [dic setValue:input.token_type forKey:@"k"];
            [dic setValue:BTCHexFromData(input.commit) forKey:@"c"];
            if (input.features != OutputFeaturePlain) {
                [dic setValue:@(input.features) forKey:@"f"];
            }
            [arr addObject:dic];
        }
        
        for (TokenOutput* output in self.tx.body.token_outputs) {
            NSMutableDictionary* dic = [NSMutableDictionary new];
            [dic setValue:output.token_type forKey:@"k"];
            [dic setValue:BTCHexFromData(output.commit) forKey:@"c"];
            [dic setValue:BTCHexFromData(output.proof) forKey:@"p"];
            [dic setValue:@(output.features) forKey:@"f"];
            
            [arr addObject:dic];
        }
        
        ret_dic[@"token_coms"] = arr;
    }

    if (self.payment_proof) {
        NSMutableDictionary* dic = [NSMutableDictionary new];
        [dic setValue:self.payment_proof.sender_address forKey:@"saddr"];
        [dic setValue:self.payment_proof.receiver_address forKey:@"raddr"];
        if (self.payment_proof.receiver_signature) {
            [dic setValue:self.payment_proof.receiver_signature forKey:@"rsig"];
        }
        
        ret_dic[@"proof"] = dic;
    }
    
    if (self.kernel_features_args) {
        NSMutableDictionary* dic = [NSMutableDictionary new];
        [dic setValue:@(self.kernel_features_args.lock_height) forKey:@"lock_hgt"];
        
        ret_dic[@"feat_args"] = dic;
    }
    
    if (self.token_kernel_features_args) {
        NSMutableDictionary* dic = [NSMutableDictionary new];
        [dic setValue:@(self.token_kernel_features_args.lock_height) forKey:@"lock_hgt"];
        
        ret_dic[@"token_feat_args"] = dic;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.version_info = [VersionCompatInfo createVersionInfo];
    
    self.uuid = dic[@"id"];
    
    NSString* stateStr = dic[@"sta"];
    if ([stateStr isEqualToString:@"NA"]) {
        self.state = Unknown;
    } else if ([stateStr isEqualToString:@"S1"]) {
        self.state = Standard1;
    } else if ([stateStr isEqualToString:@"S2"]) {
        self.state = Standard2;
    } else if ([stateStr isEqualToString:@"S3"]) {
        self.state = Standard3;
    } else if ([stateStr isEqualToString:@"I1"]) {
        self.state = Invoice1;
    } else if ([stateStr isEqualToString:@"I2"]) {
        self.state = Invoice2;
    } else if ([stateStr isEqualToString:@"I3"]) {
        self.state = Invoice3;
    }
    
    self.offset = BTCDataFromHex(dic[@"off"]);
    
    if (dic[@"num_parts"]) {
        NSNumber* num = dic[@"num_parts"];
        self.num_participants = [num unsignedIntValue];
    } else {
        self.num_participants = 2;
    }
    
    if (dic[@"amt"]) {
        NSNumber* num = dic[@"amt"];
        self.amount = [num unsignedLongLongValue];
    } else {
        self.amount = 0;
    }
    
    self.token_type = dic[@"token_type"];
    
    if (dic[@"fee"]) {
        NSNumber* num = dic[@"fee"];
        self.fee = [num unsignedLongLongValue];
    } else {
        self.fee = 0;
    }
     
    if (dic[@"feat"]) {
        NSNumber* num = dic[@"feat"];
        self.kernel_features = [num unsignedIntValue];
    } else {
        self.kernel_features = 0;
    }
    
    if (dic[@"token_feat"]) {
        NSNumber* num = dic[@"token_feat"];
        self.token_kernel_features = [num unsignedIntValue];
    } else {
        self.token_kernel_features = 0;
    }
    
    if (dic[@"ttl"]) {
        NSNumber* num = dic[@"ttl"];
        self.ttl_cutoff_height = [num unsignedLongLongValue];
    } else {
        self.ttl_cutoff_height = 0;
    }
    
    if (dic[@"sigs"]) {
        NSArray* arr = dic[@"sigs"];
        VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
        for (NSDictionary* tmpDic in arr) {
            ParticipantData* data = [ParticipantData new];
            if ([tmpDic[@"xs"] isKindOfClass:[NSString class]]){
                NSData* compressBlind_excess = BTCDataFromHex(tmpDic[@"xs"]);
                data.public_blind_excess = [secp pubkeyFromCompressedKey:compressBlind_excess];
                
            }
            
            if ([tmpDic[@"nonce"] isKindOfClass:[NSString class]]){
                NSData* compressNounce = BTCDataFromHex(tmpDic[@"nonce"]);
                data.public_nonce = [secp pubkeyFromCompressedKey:compressNounce];
            }
            
            if ([tmpDic[@"part"] isKindOfClass:[NSString class]]){
                NSData* compactPartSig = BTCDataFromHex(tmpDic[@"part"]);
                data.part_sig = [[VcashSignature alloc] initWithCompactData:compactPartSig];
            }
            
            [self.participant_data addObject:data];
        }
    }
    
    if (dic[@"coms"]) {
        NSArray* arr = dic[@"coms"];
        for (NSDictionary* tmpDic in arr) {
            NSData* commit = BTCDataFromHex(tmpDic[@"c"]);
            OutputFeatures feature = OutputFeaturePlain;
            if (tmpDic[@"f"]) {
                NSNumber* num = tmpDic[@"f"];
                feature = [num unsignedIntValue];
            }
            if (tmpDic[@"p"]) {
                NSData* proof = BTCDataFromHex(tmpDic[@"p"]);
                
                Output* output = [Output new];
                output.commit = commit;
                output.features = feature;
                output.proof = proof;
                [self.tx.body.outputs addObject:output];
            } else {
                Input* input = [Input new];
                input.commit = commit;
                input.features = feature;
                [self.tx.body.inputs addObject:input];
            }
        }
    }
    
    if (dic[@"token_coms"]) {
        NSArray* arr = dic[@"token_coms"];
        for (NSDictionary* tmpDic in arr) {
            NSString* token_type = tmpDic[@"k"];
            NSData* commit = BTCDataFromHex(tmpDic[@"c"]);
            OutputFeatures feature = OutputFeaturePlain;
            if (tmpDic[@"f"]) {
                NSNumber* num = tmpDic[@"f"];
                feature = [num unsignedIntValue];
            }
            if (tmpDic[@"p"]) {
                NSData* proof = BTCDataFromHex(tmpDic[@"p"]);
                
                TokenOutput* output = [TokenOutput new];
                output.token_type = token_type;
                output.commit = commit;
                output.features = feature;
                output.proof = proof;
                [self.tx.body.token_outputs addObject:output];
            } else {
                TokenInput* input = [TokenInput new];
                input.token_type = token_type;
                input.commit = commit;
                input.features = feature;
                [self.tx.body.token_inputs addObject:input];
            }
        }
    }
    
    if (dic[@"proof"]) {
        NSDictionary* tmpDic = dic[@"proof"];
        PaymentInfo* info = [PaymentInfo new];
        info.sender_address = tmpDic[@"saddr"];
        info.receiver_address = tmpDic[@"raddr"];
        info.receiver_signature = tmpDic[@"rsig"];
        
        self.payment_proof = info;
    }
    
    if (dic[@"feat_args"]) {
        NSDictionary* tmpDic = dic[@"feat_args"];
        KernelFeaturesArgs* arg = [KernelFeaturesArgs new];
        NSNumber* num = tmpDic[@"lock_hgt"];
        arg.lock_height = [num unsignedLongLongValue];
        self.kernel_features_args = arg;
    }
    
    if (dic[@"token_feat_args"]) {
        NSDictionary* tmpDic = dic[@"token_feat_args"];
        KernelFeaturesArgs* arg = [KernelFeaturesArgs new];
        NSNumber* num = tmpDic[@"lock_hgt"];
        arg.lock_height = [num unsignedLongLongValue];
        self.token_kernel_features_args = arg;
    }
    
    
    return YES;
}

-(VcashSecretKey*)addTxElement:(NSArray*)outputs change:(uint64_t)change changeCommitId:(VcashCommitId*)changeCommitId isForToken:(BOOL)forToken{
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    
    //2,input
    NSMutableArray* lockOutput = [NSMutableArray new];
    for (VcashOutput* item in outputs){
        if (item.status != Unspent){
            continue;
        }
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:item.keyPath];
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:item.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        Input* input = [Input new];
        input.commit = commitment;
        input.features = (item.is_coinbase?OutputFeatureCoinbase:OutputFeaturePlain);
        
//        //not include input to secret key for slatepack version
//        if (forToken) {
//            VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:item.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
//            [negativeArr addObject:secKey.data];
//        }

        [lockOutput addObject:item];
        if (forToken) {
            [self.tokenTxLog appendInput:item.commitment];
        } else {
            [self.txLog appendInput:item.commitment];
        }
        
    }
    self.lockOutputsFn = ^{
        for (VcashOutput* item in lockOutput){
            item.status = Locked;
        }
    };
    
    //output
    if (change > 0){
        VcashSecretKey* secKey = [self createTxOutputWithAmount:change changeCommitId:changeCommitId isForToken:forToken];
        [positiveArr addObject:secKey.data];
    }

    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    VcashSecretKey* blind = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    return blind;
}

-(VcashSecretKey*)addTokenTxElement:(NSArray*)token_outputs change:(uint64_t)change changeCommitId:(VcashCommitId*)changeCommitId{
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    
    NSMutableArray* lockOutput = [NSMutableArray new];
    for (VcashTokenOutput* item in token_outputs){
        if (item.status != Unspent){
            continue;
        }
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:item.keyPath];
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:item.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        TokenInput* input = [TokenInput new];
        input.token_type = item.token_type;
        input.commit = commitment;
        input.features = (item.is_token_issue?OutputFeatureTokenIssue:OutputFeatureToken);
        
        VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:item.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        [negativeArr addObject:secKey.data];
        
        [lockOutput addObject:item];
        [self.tokenTxLog appendTokenInput:item.commitment];
    }
    self.lockTokenOutputsFn = ^{
        for (VcashTokenOutput* item in lockOutput){
            item.status = Locked;
        }
    };
    
    //output
    if (change > 0){
        VcashSecretKey* secKey = [self createTxTokenOutput:self.token_type withAmount:change changeCommitId:changeCommitId];
        [positiveArr addObject:secKey.data];
    }
    
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    VcashSecretKey* blind = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    return blind;
}

-(VcashSecretKey*)addReceiverTxOutputWithChangeCommitId:(VcashCommitId*)changeCommitId{
    VcashSecretKey* secKey;
    if (self.token_type){
        secKey = [self createTxTokenOutput:self.token_type withAmount:self.amount changeCommitId:changeCommitId];
    } else {
        secKey = [self createTxOutputWithAmount:self.amount changeCommitId:changeCommitId isForToken:NO];
    }
    return secKey;
}

-(BOOL)fillRound1:(VcashContext*)context{
    if (self.token_type == NULL || self.participant_data.count == 0){
        [self generateOffset:context];
    }
    [self addParticipantInfo:context];
    return YES;
}

-(BOOL)fillRound2:(VcashContext*)context{
    //TODO check fee?
    
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSData* nonceSum = [self participantNounceSum];
    NSData* keySum = [self participantPublicBlindSum];
    NSData* msgData;
    if (self.token_type){
        msgData = [self createTokenMsgToSign];
    } else {
        msgData = [self createMsgToSign];
    }
    if (!nonceSum || !keySum || !msgData){
        return NO;
    }
    
    //1, verify part sig
    for (ParticipantData* item in self.participant_data){
        if (item.part_sig){
            if (![secp verifySingleSignature:item.part_sig pubkey:item.public_blind_excess nonceSum:nonceSum pubkeySum:keySum andMsgData:msgData]){
                DDLogError(@"----verifySingleSignature failed!");
                return NO;
            }
        }
    }
    
    //2, calcluate part sig
    VcashSecretKey* sec_key;
    if (self.token_type){
        sec_key = context.token_sec_key;
    } else {
        sec_key = context.sec_key;
    }
    VcashSignature* sig = [secp calculateSingleSignature:sec_key.data secNonce:context.sec_nounce.data nonceSum:nonceSum pubkeySum:keySum andMsgData:msgData];
    if (!sig){
        return NO;
    }
    
    NSData* pub_key = [secp getPubkeyFormSecretKey:sec_key];
    NSData* pub_nonce = [secp getPubkeyFormSecretKey:context.sec_nounce];
    
    for (ParticipantData* item in self.participant_data){
        if ([BTCHexFromData(item.public_blind_excess) isEqualToString:BTCHexFromData(pub_key)] &&
            [BTCHexFromData(item.public_nonce) isEqualToString:BTCHexFromData(pub_nonce)]){
            item.part_sig = sig;
        }
    }
    
    return YES;
}

-(void)removeOtherSigdata{
    VcashSecretKey* sec_key;
    if (self.token_type){
        sec_key = self.context.token_sec_key;
    } else {
        sec_key = self.context.sec_key;
    }
    
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSData* pub_key = [secp getPubkeyFormSecretKey:sec_key];
    NSData* pub_nonce = [secp getPubkeyFormSecretKey:self.context.sec_nounce];
    
    ParticipantData* myData = NULL;
    for (ParticipantData* item in self.participant_data){
        if ([BTCHexFromData(item.public_blind_excess) isEqualToString:BTCHexFromData(pub_key)] &&
            [BTCHexFromData(item.public_nonce) isEqualToString:BTCHexFromData(pub_nonce)]){
            myData = item;
        }
    }
    
    [self.participant_data removeAllObjects];
    [self.participant_data addObject:myData];
}

-(VcashSignature*)finalizeSignature{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSMutableArray* pubNonceArr = [NSMutableArray new];
    NSMutableArray* pubBlindArr = [NSMutableArray new];
    NSMutableArray* sigsArr = [NSMutableArray new];
    for (ParticipantData* item in self.participant_data) {
        [pubNonceArr addObject:item.public_nonce];
        [pubBlindArr addObject:item.public_blind_excess];
        [sigsArr addObject:item.part_sig];
    }
    NSData* nonceSum = [secp combinationPubkey:pubNonceArr];
    NSData* keySum = [secp combinationPubkey:pubBlindArr];
    
    //calcluate group signature
    VcashSignature* finalSig = [secp combinationSignature:sigsArr nonceSum:nonceSum];
    NSData* msgData;
    if (self.token_type) {
        msgData = [self createTokenMsgToSign];
    } else {
        msgData = [self createMsgToSign];
    }
    
    if (finalSig && msgData){
        BOOL yesOrNO = [secp verifySingleSignature:finalSig pubkey:keySum nonceSum:nil pubkeySum:keySum andMsgData:msgData];
        if (yesOrNO){
            return finalSig;
        }
    }
    
    return nil;
}

-(BOOL)finalizeTx:(VcashSignature*)finalSig{
    //TODO check fee?
    if (self.token_type) {
        //finalize parent tx first
        VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
        NSData* final_excess = [self.tx calculateFinalExcess];
        NSData* pubKey = [secp commitToPubkey:final_excess];
        NSData* msgData = [self createMsgToSign];
        VcashSignature* sig = [secp calculateSingleSignature:self.context.sec_key.data secNonce:nil nonceSum:nil pubkeySum:pubKey andMsgData:msgData];
        if (!sig){
            DDLogError(@"calculate token parent tx signature failed");
            return NO;
        }
        if (![self.tx setTxExcess:final_excess andTxSig:sig]){
            DDLogError(@"verify token parent tx excess failed");
            return NO;
        }
        
        NSData* final_token_excess = [self calculateExcess];
        if ([self.tx setTokenTxExcess:final_token_excess andTxSig:finalSig]){
            return YES;
        }
    } else {
        NSData* final_excess = [self calculateExcess];
        if ([self.tx setTxExcess:final_excess andTxSig:finalSig]){
            return YES;
        }
    }
    
    return NO;
}

-(void)subInputFromOffset:(VcashContext*)context {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    [positiveArr addObject:self.offset];
    
    for (VcashCommitId* commitId in context.input_ids) {
        VcashSecretKey* key = [[VcashWallet shareInstance].mKeyChain deriveKey:commitId.value andKeypath:[[VcashKeychainPath alloc] initWithPathstr:commitId.keyPath] andSwitchType:SwitchCommitmentTypeRegular];
        [negativeArr addObject:key.data];
    }
    
    VcashSecretKey* new_offset = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    self.offset = new_offset.data;
    self.tx.offset = new_offset.data;
}

-(void)repopulateTx:(VcashContext*)context {
    // restore the original amount, fee
    self.amount = context.amount;
    self.fee = context.fee;
    
    VcashSecretKey* sec_key = context.sec_key;
    if (context.token_sec_key) {
        sec_key = context.token_sec_key;
    }
    
    if (self.participant_data.count == 1) {
        VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
        NSData* pub_key = [secp getPubkeyFormSecretKey:sec_key];
        NSData* pub_nonce = [secp getPubkeyFormSecretKey:context.sec_nounce];
        
        ParticipantData* item = [ParticipantData new];
        item.public_blind_excess = pub_key;
        item.public_nonce = pub_nonce;
        [self.participant_data addObject:item];
    }

    for (VcashCommitId* commitId in context.input_ids) {
        NSData* commit = [[VcashWallet shareInstance].mKeyChain createCommitment:commitId.value andKeypath:[[VcashKeychainPath alloc] initWithPathstr:commitId.keyPath] andSwitchType:SwitchCommitmentTypeRegular];
        
        VcashOutput* output = [[VcashWallet shareInstance] findOutputByCommit:BTCHexFromData(commit)];
        
        Input* input = [Input new];
        input.commit = commit;
        input.features = output.is_coinbase?OutputFeatureCoinbase:OutputFeaturePlain;
        [self.tx.body.inputs addObject:input];
    }
    
    for (VcashCommitId* commitId in context.token_input_ids) {
        NSData* commit = [[VcashWallet shareInstance].mKeyChain createCommitment:commitId.value andKeypath:[[VcashKeychainPath alloc] initWithPathstr:commitId.keyPath] andSwitchType:SwitchCommitmentTypeRegular];
        
        VcashTokenOutput* output = [[VcashWallet shareInstance] findTokenOutputByCommit:BTCHexFromData(commit)];
        
        TokenInput* input = [TokenInput new];
        input.token_type = output.token_type;
        input.commit = commit;
        input.features = output.is_token_issue?OutputFeatureTokenIssue:OutputFeatureToken;
        [self.tx.body.token_inputs addObject:input];
    }
    
    for (VcashCommitId* commitId in context.output_ids) {
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:commitId.keyPath];
        NSData* commit = [[VcashWallet shareInstance].mKeyChain createCommitment:commitId.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:commitId.value withKeyPath:keypath];
        
        Output* output = [Output new];
        output.features = OutputFeaturePlain;
        output.commit = commit;
        output.proof = proof;
        [self.tx.body.outputs addObject:output];
    }
    
    for (VcashCommitId* commitId in context.token_output_ids) {
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:commitId.keyPath];
        NSData* commit = [[VcashWallet shareInstance].mKeyChain createCommitment:commitId.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:commitId.value withKeyPath:keypath];
        
        TokenOutput* output = [TokenOutput new];
        output.features = OutputFeatureToken;
        output.commit = commit;
        output.proof = proof;
        output.token_type = self.token_type;
        [self.tx.body.token_outputs addObject:output];
    }
    
    TxKernel* kernel = [TxKernel new];
    kernel.features = self.kernel_features;
    kernel.fee = self.fee;
    if (self.kernel_features_args) {
        kernel.lock_height = self.kernel_features_args.lock_height;
    }
    [self.tx.body.kernels addObject:kernel];
    
    if (self.token_type) {
        TokenTxKernel* tokenKernel = [TokenTxKernel new];
        tokenKernel.features = self.token_kernel_features;
        tokenKernel.token_type = self.token_type;
        if (self.token_kernel_features_args) {
            tokenKernel.lock_height = self.token_kernel_features_args.lock_height;
        }
        [self.tx.body.token_kernels addObject:tokenKernel];
        
    }
}

#pragma private
-(VcashSecretKey*)createTxOutputWithAmount:(uint64_t)amount changeCommitId:(VcashCommitId*)changeCommitId isForToken:(BOOL)isForToken{
    VcashKeychainPath* keypath = [[VcashWallet shareInstance] nextChild];
    NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:amount andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
    NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:amount withKeyPath:keypath];
    Output* output = [Output new];
    output.features = OutputFeaturePlain;
    output.commit = commitment;
    output.proof = proof;
    
    [self.tx.body.outputs addObject:output];
    VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:amount andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
    
    changeCommitId.keyPath = keypath.pathStr;
    changeCommitId.value = amount;
    
    __weak typeof (self) weak_self = self;
    self.createNewOutputsFn = ^{
        __strong typeof (weak_self) strong_self = weak_self;
        VcashOutput* output = [VcashOutput new];
        output.commitment = BTCHexFromData(commitment);
        output.keyPath = keypath.pathStr;
        output.value = amount;
        output.lock_height = 0;
        output.is_coinbase = NO;
        output.status = Unconfirmed;
        if (isForToken) {
            output.tx_log_id = strong_self.tokenTxLog.tx_id;
            [strong_self.tokenTxLog appendOutput:output.commitment];
        } else {
            output.tx_log_id = strong_self.txLog.tx_id;
            [strong_self.txLog appendOutput:output.commitment];
        }
        
        [[VcashWallet shareInstance] addNewTxChangeOutput:output];
    };
    
    return secKey;
}

-(VcashSecretKey*)createTxTokenOutput:(NSString*)tokenType withAmount:(uint64_t)amount changeCommitId:(VcashCommitId*)changeCommitId{
    VcashKeychainPath* keypath = [[VcashWallet shareInstance] nextChild];
    NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:amount andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
    NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:amount withKeyPath:keypath];
    TokenOutput* output = [TokenOutput new];
    output.token_type = tokenType;
    output.features = OutputFeatureToken;
    output.commit = commitment;
    output.proof = proof;
    
    [self.tx.body.token_outputs addObject:output];
    VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:amount andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
    
    changeCommitId.keyPath = keypath.pathStr;
    changeCommitId.value = amount;
    
    __weak typeof (self) weak_self = self;
    self.createNewTokenOutputsFn = ^{
        __strong typeof (weak_self) strong_self = weak_self;
        VcashTokenOutput* output = [VcashTokenOutput new];
        output.token_type = tokenType;
        output.commitment = BTCHexFromData(commitment);
        output.keyPath = keypath.pathStr;
        output.value = amount;
        output.lock_height = 0;
        output.is_token_issue = NO;
        output.status = Unconfirmed;
        output.tx_log_id = strong_self.tokenTxLog.tx_id;
        [strong_self.tokenTxLog appendTokenOutput:output.commitment];
        
        [[VcashWallet shareInstance] addNewTokenTxChangeOutput:output];
    };
    
    return secKey;
}

-(void)generateOffset:(VcashContext*)context{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSData* mOffset = [VcashSecretKey nounceKey].data;
    NSMutableArray<NSData*>* offsetArr = [NSMutableArray new];
    [offsetArr addObject:self.offset];
    [offsetArr addObject:mOffset];
    VcashSecretKey* total_offset = [secp blindSumWithPositiveArr:offsetArr andNegative:nil];
    self.offset = total_offset.data;
    
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    [positiveArr addObject:context.sec_key.data];
    [negativeArr addObject:mOffset];
    VcashSecretKey* blind = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    context.sec_key = blind;
}

-(void)addParticipantInfo:(VcashContext*)context {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    VcashSecretKey* sec_key = context.sec_key;
    if (context.token_sec_key) {
        sec_key = context.token_sec_key;
    }
    NSData* pub_key = [secp getPubkeyFormSecretKey:sec_key];
    NSData* pub_nonce = [secp getPubkeyFormSecretKey:context.sec_nounce];
    
    ParticipantData* partiData = [ParticipantData new];
    partiData.public_nonce = pub_nonce;
    partiData.public_blind_excess = pub_key;
    
    [self.participant_data addObject:partiData];
}

-(NSData*)createMsgToSign{
    TxKernel* kernel = [TxKernel new];
    kernel.features = self.kernel_features;
    kernel.fee = self.fee;
    if (self.kernel_features_args) {
        kernel.lock_height = self.kernel_features_args.lock_height;
    }
    
    return [kernel kernelMsgToSign];
}

-(NSData*)createTokenMsgToSign{
    TokenTxKernel* tokenKernel = [TokenTxKernel new];
    tokenKernel.features = self.token_kernel_features;
    tokenKernel.token_type = self.token_type;
    if (self.token_kernel_features_args) {
        tokenKernel.lock_height = self.token_kernel_features_args.lock_height;
    }
    return [tokenKernel kernelMsgToSign];
}

-(NSData*)calculateExcess{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSData* keySum = [self participantPublicBlindSum];
    NSData* commit = [secp pubkeyToCommit:keySum];
    
    return commit;
}

-(NSData*)participantPublicBlindSum{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSMutableArray* pubBlindArr = [NSMutableArray new];
    for (ParticipantData* item in self.participant_data) {
        [pubBlindArr addObject:item.public_blind_excess];
    }
    NSData* keySum = [secp combinationPubkey:pubBlindArr];
    return keySum;
}

-(NSData*)participantNounceSum{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSMutableArray* pubNonceArr = [NSMutableArray new];

    for (ParticipantData* item in self.participant_data) {
        [pubNonceArr addObject:item.public_nonce];
    }
    NSData* nonceSum = [secp combinationPubkey:pubNonceArr];
    return nonceSum;
}

-(BOOL)isValidForReceive{
    if (self.participant_data.count != 1){
        return NO;
    }
    
    if (self.amount == 0 || self.fee == 0){
        return NO;
    }
    
    return YES;
}

-(BOOL)isValidForFinalize{
    if (self.participant_data.count != 2){
        return NO;
    }
    
    if (self.tx.body.inputs.count == 0 || self.tx.body.kernels.count == 0){
        return NO;
    }
    
    return YES;
}

@end

@implementation VersionCompatInfo

+(instancetype)createVersionInfo{
    VersionCompatInfo* info = [VersionCompatInfo new];
    info.version= 4;
    info.block_header_version = 3;
    return info;
}

@end

@implementation ParticipantData

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"public_blind_excess":@"xs",
             @"public_nonce":@"nonce",
             @"part_sig":@"part",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    if ([dic[@"xs"] isKindOfClass:[NSString class]]){
        NSData* compressBlind_excess = BTCDataFromHex(dic[@"xs"]);
        self.public_blind_excess = [secp pubkeyFromCompressedKey:compressBlind_excess];
        
    }
    
    if ([dic[@"nonce"] isKindOfClass:[NSString class]]){
        NSData* compressNounce = BTCDataFromHex(dic[@"nonce"]);
        self.public_nonce = [secp pubkeyFromCompressedKey:compressNounce];
    }
    
    if ([dic[@"part"] isKindOfClass:[NSString class]]){
        NSData* compactPartSig = BTCDataFromHex(dic[@"part"]);
        self.part_sig = [[VcashSignature alloc] initWithCompactData:compactPartSig];
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    if (self.public_blind_excess){
        NSData* compressed = [secp getCompressedPubkey:self.public_blind_excess];
        dic[@"xs"] = BTCHexFromData(compressed);
    }
    else{
        dic[@"xs"] = [NSNull null];
    }

    if (self.public_nonce){
        NSData* noncecompressed = [secp getCompressedPubkey:self.public_nonce];
        dic[@"nonce"] = BTCHexFromData(noncecompressed);
    }
    else{
        dic[@"nonce"] = [NSNull null];
    }
    
    if (self.part_sig) {
        NSData* compactPartSig = [self.part_sig getCompactData];
        dic[@"part"] = BTCHexFromData(compactPartSig);
        //dic[@"part_sig"] = BTCHexFromData(self.part_sig.sig_data);
    }
    else{
        dic[@"part"] = [NSNull null];
    }
    
    return YES;
}

@end

@implementation PaymentInfo

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (!self.receiver_signature){
        dic[@"receiver_signature"] = [NSNull null];
    }
    
    return YES;
}

@end

@implementation KernelFeaturesArgs

@end
