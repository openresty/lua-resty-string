# vi:ft=

use Test::Nginx::Socket;

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

our $HttpConfig = <<'_EOC_';
    #lua_code_cache off;
    lua_package_path 'lib/?.lua;;';
    lua_package_cpath 'lib/?.so;;';
_EOC_

no_long_string();

run_tests();

__DATA__

=== TEST 1: hello HMAC-SHA-1
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha1 = require "resty.hmac"
            local hmac_sha1 = resty_hmac_sha1:new()

            local digest = hmac_sha1:digest("sha1","secret-key","Hello world")
            ngx.say("hmac_sha1: ", digest)

            --test with an empty string
            digest = hmac_sha1:digest("sha1","secret-key","")
            ngx.say("hmac_sha1: ", digest)
        ';
    }
--- request
GET /t
--- response_body
hmac_sha1: 3a20c85ba3af4c1b1eec24c672cfb3db803e3637
hmac_sha1: 0877fcf3af864ddf56157f9f4e39eb48dedd74fd
--- no_error_log
[error]

=== TEST 2: hello HMAC-SHA-224
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha224 = require "resty.hmac"
            local hmac_sha224 = resty_hmac_sha224:new()

            local digest = hmac_sha224:digest("sha224","secret-key","Hello world")
            ngx.say("hmac_sha224: ", digest)

            --test with an empty string
            digest = hmac_sha224:digest("sha224","secret-key","")
            ngx.say("hmac_sha224: ", digest)
        ';
    }
--- request
GET /t
--- response_body
hmac_sha224: a38aa774b3d7f49e6f3a7006cdfac9f8aeab4427dd3fb47123be5874
hmac_sha224: a41ef5660a729abe83238c6921861ddd157a2314df03d98252a9ecac
--- no_error_log
[error]


=== TEST 3: hello HMAC-SHA-256
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha256 = require "resty.hmac"
            local hmac_sha256 = resty_hmac_sha256:new()

            local digest = hmac_sha256:digest("sha256","secret-key","Hello world")
            ngx.say("hmac_sha256: ", digest)

            --test with an empty string
            digest = hmac_sha256:digest("sha256","secret-key","")
            ngx.say("hmac_sha256: ", digest)
        ';
    }
--- request
GET /t
--- response_body
hmac_sha256: 902dd133c19fef9216f144694b1b9cc9e06c7be3252019f7e12909ff07122220
hmac_sha256: 345fba21f06a4f75ed673fb93dc16cd47d8dc7a69f52e84e3016fcf69835fdb8
--- no_error_log
[error]


=== TEST 4: hello HMAC-SHA-384
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha384 = require "resty.hmac"
            local hmac_sha384 = resty_hmac_sha384:new()

            local digest = hmac_sha384:digest("sha384","secret-key","Hello world")
            ngx.say("hmac_sha384: ", digest)

            --test with an empty string
            digest = hmac_sha384:digest("sha384","secret-key","")
            ngx.say("hmac_sha384: ", digest)
        ';
    }
--- request
GET /t
--- response_body
hmac_sha384: 7baab15202e53288e026c9b318c08527692ad27ef8903bcb405bcd097e4ed7611cb542d760234ef04536da3a16e906bf
hmac_sha384: 3e4c852a0ce874f8bef33bb899b7fa938f5ce8418bafc530e7c2df532b7be4ad49f5b57ca49c50d9080c16b74ef124dc
--- no_error_log
[error]



=== TEST 5: hello HMAC-SHA-512
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha512 = require "resty.hmac"
            local hmac_sha512 = resty_hmac_sha512:new()

            local digest = hmac_sha512:digest("sha512","secret-key","Hello world")
            ngx.say("hmac_sha512: ", digest)

            --test with an empty string
            digest = hmac_sha512:digest("sha512","secret-key","")
            ngx.say("hmac_sha512: ", digest)
        ';
    }
--- request
GET /t
--- response_body
hmac_sha512: cbec52174d245ed147e57860e9317605895e1b4af43b080701bccb083f2194cd3ada40623420c2ab1b4c77ce6e6d26b149128867035eba259d495524fa230dee
hmac_sha512: 1560eeb87551d027de6007027af3faab5f644f8ef96519c4b519531a6620c755b61d210f179754f991607151b4b9a9db3377132b9e8587f803cdf8763499bcdc
--- no_error_log
[error]

=== TEST 6: test with an invalid HMAC algorithm
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha256 = require "resty.hmac"
            local hmac_sha256 = resty_hmac_sha256:new()

            local digest = hmac_sha256:digest("INVALID_SHA","secret-key","Hello world")
            ngx.say("hmac_sha256: ", digest)

            --test with an empty string
            digest = hmac_sha256:digest("INVALID_SHA","secret-key","")
            ngx.say("hmac_sha256: ", digest)
        ';
    }
--- request
GET /t
--- response_body_like
.*500 Internal Server Error.*
--- error_code: 500
--- grep_error_log eval: qr/attempt to use unknown algorithm: 'INVALID_SHA'.*?/
--- grep_error_log_out
attempt to use unknown algorithm: 'INVALID_SHA'

=== TEST 7: test with null secret or message
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local resty_hmac_sha256 = require "resty.hmac"
            local hmac_sha256 = resty_hmac_sha256:new()

            local digest = hmac_sha256:digest("sha256",nil,"Hello world")
            ngx.say("hmac_sha256: ", digest)

            digest = hmac_sha256:digest("sha256",nil,"")
            ngx.say("hmac_sha256: ", digest)
        ';
    }
--- request
GET /t
--- response_body_like
.*500 Internal Server Error.*
--- error_code: 500
--- grep_error_log eval: qr/attempt to digest with a null key or message.*?/
--- grep_error_log_out
attempt to digest with a null key or message



