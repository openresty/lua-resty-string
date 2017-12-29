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

=== TEST 1: murmur_hash2
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local murmur = require "resty.murmur"
            ngx.say(murmur.murmur_hash2("hello world"))
        }
    }
--- request
GET /t
--- response_body
1151865881
--- no_error_log
[error]

=== TEST 2: murmur hash2 empty string
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local murmur = require "resty.murmur"
            ngx.say(murmur.murmur_hash2(""))
        }
    }
--- request
GET /t
--- response_body
0
--- no_error_log
[error]
