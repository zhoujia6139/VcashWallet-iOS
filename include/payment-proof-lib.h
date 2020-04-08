//
// Created by jdwldnqi837 on 2020-04-02.
//

#ifndef PAYMENT_PROOF_LIB_PAYMENT_PROOF_LIB_H
#define PAYMENT_PROOF_LIB_PAYMENT_PROOF_LIB_H

#include <stdint.h>

const char* address(const char* private_key);

const char* base32_address_to_pubkey_address(const char* base32_address);

const char* create_payment_proof_signature(const char* msg, const char* private_key);

bool verify_payment_proof(const char* msg, const char* pub_key, const char* signature);


#endif //PAYMENT_PROOF_LIB_PAYMENT_PROOF_LIB_H
