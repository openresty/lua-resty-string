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

=== TEST 1: hello CRC32 
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_crc32 = require "resty.crc32"
            local str = require "resty.string"
            local crc32 = resty_crc32:new()
            ngx.say(crc32:update("hello"))
            local digest = crc32:final()
            ngx.say(digest == ngx.crc32_short("hello"))
            ngx.say("crc32: ", digest)
        ';
    }
--- request
GET /t
--- response_body
907060870
true
crc32: 907060870
--- no_error_log
[error]



=== TEST 2: CRC32 incremental
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_crc32 = require "resty.crc32"
            local str = require "resty.string"
            local crc32 = resty_crc32:new()
            ngx.say(crc32:update("hel"))
            ngx.say(crc32:update("lo"))
            local digest = crc32:final()
            ngx.say("crc32: ", digest)
        ';
    }
--- request
GET /t
--- response_body
3842765083
907060870
crc32: 907060870
--- no_error_log
[error]



=== TEST 3: CRC32 empty string
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_crc32 = require "resty.crc32"
            local str = require "resty.string"
            local crc32 = resty_crc32:new()
            ngx.say(crc32:update(""))
            local digest = crc32:final()
            ngx.say(digest == ngx.crc32_short(""))
            ngx.say("crc32: ", digest)
        ';
    }
--- request
GET /t
--- response_body
0
true
crc32: 0
--- no_error_log
[error]

