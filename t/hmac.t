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

=== TEST 1: hmac
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local hmac = require "resty.hmac"
            local str = require "resty.string"
            local key = "40A4510F290AD8182AF4B0260C655F8511E5B46BCA20EA191D8BC7B4D99CE95F&1610354610892"
            local data = "test&f31a8c01e125e4720481be05:755eccf6aa0cd51d55ad0c9a61f5a3cc3089bbe7de00a3dd484a1d&1610354610892"
            local md, err = hmac.HMAC(key, data, hmac.hash.sha256)
            if err ~= nil then
                ngx.say(err)
                ngx.exit(0)
            end
            ngx.say("MD5: ", str.to_hex(md))
        ';
    }
--- request
GET /t
--- response_body
MD5: 3e623fe00dd0f948c1141367e81c1819794051c76e3199782129a280d499de08
--- no_error_log
[error]



=== TEST 2: hmac
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local hmac = require "resty.hmac"
            local str = require "resty.string"
            local key = "456"
            local data = "123"
            local md, err = hmac.HMAC(key, data, hmac.hash.sha256)
            if err ~= nil then
                ngx.say(err)
                ngx.exit(0)
            end
            ngx.say("SHA256: ", str.to_hex(md))
        ';
    }
--- request
GET /t
--- response_body
SHA256: 3ab82fc5e7544cb11b7a62993652b0bed2c3e31abfc58b3c1143ae29f7b316c8
--- no_error_log
[error]
