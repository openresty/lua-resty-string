-- Copyright (C) by Yichun Zhang (agentzh)


local ffi = require "ffi"

local _M = { _VERSION = '0.09' }

if not pcall(ffi.typeof, "evp_cipher_ctx_st") then
    ffi.cdef[[
        typedef struct engine_st ENGINE;

        typedef struct evp_cipher_st EVP_CIPHER;
        typedef struct evp_cipher_ctx_st
        {
            const EVP_CIPHER *cipher;
            ENGINE *engine;
            int encrypt;
            int buf_len;

            unsigned char  oiv[16];
            unsigned char  iv[16];
            unsigned char buf[32];
            int num;

            void *app_data;
            int key_len;
            unsigned long flags;
            void *cipher_data;
            int final_used;
            int block_mask;
            unsigned char final[32];
        } EVP_CIPHER_CTX;

        typedef struct env_md_ctx_st EVP_MD_CTX;
        typedef struct env_md_st EVP_MD;

        const EVP_MD *EVP_md5(void);
        const EVP_MD *EVP_sha(void);
        const EVP_MD *EVP_sha1(void);
        const EVP_MD *EVP_sha224(void);
        const EVP_MD *EVP_sha256(void);
        const EVP_MD *EVP_sha384(void);
        const EVP_MD *EVP_sha512(void);

        void EVP_CIPHER_CTX_init(EVP_CIPHER_CTX *a);
        int EVP_CIPHER_CTX_cleanup(EVP_CIPHER_CTX *a);

        int EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx,const EVP_CIPHER *cipher,
            ENGINE *impl, unsigned char *key, const unsigned char *iv);

        int EVP_EncryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
            const unsigned char *in, int inl);

        int EVP_EncryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl);

        int EVP_DecryptInit_ex(EVP_CIPHER_CTX *ctx,const EVP_CIPHER *cipher,
            ENGINE *impl, unsigned char *key, const unsigned char *iv);

        int EVP_DecryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
            const unsigned char *in, int inl);

        int EVP_DecryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *outm, int *outl);

        int EVP_BytesToKey(const EVP_CIPHER *type,const EVP_MD *md,
            const unsigned char *salt, const unsigned char *data, int datal,
            int count, unsigned char *key,unsigned char *iv);
    ]]
end

return _M
