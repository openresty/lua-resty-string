# vi:ft=

use Test::Nginx::Socket::Lua;

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

our $HttpConfig = <<'_EOC_';
    lua_package_path 'lib/?.lua;;';
    lua_package_cpath 'lib/?.so;;';
_EOC_

#log_level 'warn';

run_tests();

__DATA__

=== TEST 1: DES default hello
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("secret")
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES CBC MD5: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
        ';
    }
--- request
GET /t
--- response_body
DES CBC MD5: 3028fdfc7b74aaec
true
--- no_error_log
[error]



=== TEST 2: DES empty key hello
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("")
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES (empty key) CBC MD5: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
        ';
    }
--- request
GET /t
--- response_body
DES (empty key) CBC MD5: 6b0a3800575fa05a
true
--- no_error_log
[error]



=== TEST 3: DES 8-byte salt
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("secret","WhatSalt")
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES (salted) CBC MD5: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
        ';
    }
--- request
GET /t
--- response_body
DES (salted) CBC MD5: 76d148298c71102b
true
--- no_error_log
[error]



=== TEST 4: DES oversized 10-byte salt
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("secret","Oversized!")
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES (oversized salt) CBC MD5: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
            local des_check = des:new("secret","Oversize")
            local encrypted_check = des_check:encrypt("hello")
            ngx.say(encrypted_check == encrypted)
        ';
    }
--- request
GET /t
--- response_body
DES (oversized salt) CBC MD5: 1f1b7f7d3d878c0d
true
true
--- no_error_log
[error]



=== TEST 5: DES ECB SHA1 no salt
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("secret",nil,
              des.cipher("ecb"),des.hash.sha1)
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES ECB SHA1: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
        ';
    }
--- request
GET /t
--- response_body
DES ECB SHA1: 990d687fb296268f
true
--- no_error_log
[error]



=== TEST 6: DES ECB SHA1x5 no salt
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("secret",nil,
              des.cipher("ecb"),des.hash.sha1,5)
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES ECB SHA1: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
        ';
    }
--- request
GET /t
--- response_body
DES ECB SHA1: 181a53a4de55ae07
true
--- no_error_log
[error]



=== TEST 7: DES CBC custom keygen
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("Xr4ilOzQ4PA=",nil,
              des.cipher("cbc"),
              {iv = ngx.decode_base64("jqt2kNKm7mk="),
               method = ngx.decode_base64})
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES CBC (custom keygen) MD5: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
            local des_check = des:new("secret")
            local encrypted_check = des_check:encrypt("hello")
            ngx.say(encrypted_check == encrypted)
        ';
    }
--- request
GET /t
--- response_body
DES CBC (custom keygen) MD5: 3028fdfc7b74aaec
true
true
--- no_error_log
[error]



=== TEST 8: DES CBC custom keygen (without method)
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new(ngx.decode_base64("Xr4ilOzQ4PA="),nil,
              des.cipher("cbc"),
              {iv = ngx.decode_base64("jqt2kNKm7mk=")})
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES CBC (custom keygen) MD5: ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
            local des_check = des:new("secret")
            local encrypted_check = des_check:encrypt("hello")
            ngx.say(encrypted_check == encrypted)
        ';
    }
--- request
GET /t
--- response_body
DES CBC (custom keygen) MD5: 3028fdfc7b74aaec
true
true
--- no_error_log
[error]



=== TEST 9: DES CBC custom keygen (without method, bad key len)
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"

            local des_default, err = des:new("hel", nil, des.cipher("cbc"),
              {iv = ngx.decode_base64("jqt2kNKm7mk=")})

            if not des_default then
                ngx.say("failed to new: ", err)
                return
            end
        ';
    }
--- request
GET /t
--- response_body
failed to new: bad key length
--- no_error_log
[error]



=== TEST 10: DES CBC custom keygen (without method, bad iv)
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"

            local des_default, err = des:new(
                ngx.decode_base64("Xr4ilOzQ4PA="),
                nil,
                des.cipher("cbc"),
                {iv = "hello"}
            )

            if not des_default then
                ngx.say("failed to new: ", err)
                return
            end
        ';
    }
--- request
GET /t
--- response_body
failed to new: bad iv
--- no_error_log
[error]



=== TEST 11: DES CBC custom key iv
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local des = require "resty.des"
            local str = require "resty.string"
            local des_default = des:new("abcdefgh",nil,
              des.cipher("cbc"),
              {iv = "12345678"})
            local encrypted = des_default:encrypt("hello")
            ngx.say("DES CBC (custom key iv): ", str.to_hex(encrypted))
            local decrypted = des_default:decrypt(encrypted)
            ngx.say(decrypted == "hello")
        ';
    }
--- request
GET /t
--- response_body
DES CBC (custom key iv): f129f0fbf12641d6
true
--- no_error_log
[error]
