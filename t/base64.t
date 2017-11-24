# vi:ft=

use Test::Nginx::Socket::Lua;

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

our $HttpConfig = <<'_EOC_';
    lua_package_path 'lib/?.lua;;';
    lua_package_cpath 'lib/?.so;;';
_EOC_

no_long_string();

run_tests();

__DATA__

=== TEST 1: encode_base64
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local b64 = require("resty.base64")
            -- RFC 4648 test vectors
            ngx.say("encode_base64(\"\") = \"", b64.encode_base64(""), "\"")
            ngx.say("encode_base64(\"f\") = \"", b64.encode_base64("f"), "\"")
            ngx.say("encode_base64(\"fo\") = \"", b64.encode_base64("fo"), "\"")
            ngx.say("encode_base64(\"foo\") = \"", b64.encode_base64("foo"), "\"")
            ngx.say("encode_base64(\"foob\") = \"", b64.encode_base64("foob"), "\"")
            ngx.say("encode_base64(\"fooba\") = \"", b64.encode_base64("fooba"), "\"")
            ngx.say("encode_base64(\"foobar\") = \"", b64.encode_base64("foobar"), "\"")
            ngx.say("encode_base64(\"\\xff\") = \"", b64.encode_base64("\xff"), "\"")
        }
    }
--- request
GET /t
--- response_body
encode_base64("") = ""
encode_base64("f") = "Zg=="
encode_base64("fo") = "Zm8="
encode_base64("foo") = "Zm9v"
encode_base64("foob") = "Zm9vYg=="
encode_base64("fooba") = "Zm9vYmE="
encode_base64("foobar") = "Zm9vYmFy"
encode_base64("\xff") = "/w=="
--- no_error_log
[error]



=== TEST 2: encode_base64url
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local b64 = require("resty.base64")
            -- RFC 4648 test vectors
            ngx.say("encode_base64url(\"\") = \"", b64.encode_base64url(""), "\"")
            ngx.say("encode_base64url(\"f\") = \"", b64.encode_base64url("f"), "\"")
            ngx.say("encode_base64url(\"fo\") = \"", b64.encode_base64url("fo"), "\"")
            ngx.say("encode_base64url(\"foo\") = \"", b64.encode_base64url("foo"), "\"")
            ngx.say("encode_base64url(\"foob\") = \"", b64.encode_base64url("foob"), "\"")
            ngx.say("encode_base64url(\"fooba\") = \"", b64.encode_base64url("fooba"), "\"")
            ngx.say("encode_base64url(\"foobar\") = \"", b64.encode_base64url("foobar"), "\"")
            ngx.say("encode_base64url(\"\\xff\") = \"", b64.encode_base64url("\xff"), "\"")
        }
    }
--- request
GET /t
--- response_body
encode_base64url("") = ""
encode_base64url("f") = "Zg"
encode_base64url("fo") = "Zm8"
encode_base64url("foo") = "Zm9v"
encode_base64url("foob") = "Zm9vYg"
encode_base64url("fooba") = "Zm9vYmE"
encode_base64url("foobar") = "Zm9vYmFy"
encode_base64url("\xff") = "_w"
--- no_error_log
[error]



=== TEST 3: decode_base64
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local b64 = require("resty.base64")
            local to_hex = require("resty.string").to_hex
            -- RFC 4648 test vectors
            ngx.say("decode_base64(\"\") = \"", b64.decode_base64(""), "\"")
            ngx.say("decode_base64(\"Zg==\") = \"", b64.decode_base64("Zg=="), "\"")
            ngx.say("decode_base64(\"Zm8=\") = \"", b64.decode_base64("Zm8="), "\"")
            ngx.say("decode_base64(\"Zm9v\") = \"", b64.decode_base64("Zm9v"), "\"")
            ngx.say("decode_base64(\"Zm9vYg==\") = \"", b64.decode_base64("Zm9vYg=="), "\"")
            ngx.say("decode_base64(\"Zm9vYmE=\") = \"", b64.decode_base64("Zm9vYmE"), "\"")
            ngx.say("decode_base64(\"Zm9vYmFy\") = \"", b64.decode_base64("Zm9vYmFy"), "\"")
            ngx.say("decode_base64(\"/w==\") = \"\\x", to_hex(b64.decode_base64("/w==")), "\"")
        }
    }
--- request
GET /t
--- response_body
decode_base64("") = ""
decode_base64("Zg==") = "f"
decode_base64("Zm8=") = "fo"
decode_base64("Zm9v") = "foo"
decode_base64("Zm9vYg==") = "foob"
decode_base64("Zm9vYmE=") = "fooba"
decode_base64("Zm9vYmFy") = "foobar"
decode_base64("/w==") = "\xff"
--- no_error_log
[error]



=== TEST 4: decode_base64url
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local b64 = require("resty.base64")
            local to_hex = require("resty.string").to_hex
            -- RFC 4648 test vectors
            ngx.say("decode_base64url(\"\") = \"", b64.decode_base64url(""), "\"")
            ngx.say("decode_base64url(\"Zg\") = \"", b64.decode_base64url("Zg"), "\"")
            ngx.say("decode_base64url(\"Zm8\") = \"", b64.decode_base64url("Zm8"), "\"")
            ngx.say("decode_base64url(\"Zm9v\") = \"", b64.decode_base64url("Zm9v"), "\"")
            ngx.say("decode_base64url(\"Zm9vYg\") = \"", b64.decode_base64url("Zm9vYg"), "\"")
            ngx.say("decode_base64url(\"Zm9vYmE\") = \"", b64.decode_base64url("Zm9vYmE"), "\"")
            ngx.say("decode_base64url(\"Zm9vYmFy\") = \"", b64.decode_base64url("Zm9vYmFy"), "\"")
            ngx.say("decode_base64url(\"_w\") = \"\\x", to_hex(b64.decode_base64url("_w")), "\"")
        }
    }
--- request
GET /t
--- response_body
decode_base64url("") = ""
decode_base64url("Zg") = "f"
decode_base64url("Zm8") = "fo"
decode_base64url("Zm9v") = "foo"
decode_base64url("Zm9vYg") = "foob"
decode_base64url("Zm9vYmE") = "fooba"
decode_base64url("Zm9vYmFy") = "foobar"
decode_base64url("_w") = "\xff"
--- no_error_log
[error]
