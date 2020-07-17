//
// Created by jdwldnqi837 on 2020-04-02.
//

#ifndef PAYMENT_PROOF_LIB_PAYMENT_PROOF_LIB_H
#define PAYMENT_PROOF_LIB_PAYMENT_PROOF_LIB_H

#include <stdint.h>

const char* slate_address(const char* private_key, bool is_test);

const char* slate_address_to_pubkey_address(const char* slate_address);

const char* pubkey_address_to_slate_address(const char* pubkey_address, bool is_test);

const char* create_payment_proof_signature(const char* msg, const char* private_key);

bool verify_payment_proof(const char* msg, const char* pub_key, const char* signature);

const char* create_slatepack_message(const char* slate_bin, const char* receiver_addr, const char*  sender_addr);

const char* slate_from_slatepack_message(const char* slate_pack, const char* secret_key);

const char* sender_address_from_slatepack_message(const char* slate_pack, const char* secret_key);

void c_str_free(const char* c_raw_strr);

//uuid
const char* create_random_uuid(void);

const char* bytes_from_uuid(const char* uuid_str);

const char* uuid_from_bytes(const char* bin_str);


#endif //PAYMENT_PROOF_LIB_PAYMENT_PROOF_LIB_H
