# vi:ft=

use Test::Nginx::Socket;

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

our $HttpConfig = <<'_EOC_';
    lua_package_path 'lib/?.lua;;';
    lua_package_cpath 'lib/?.so;;';
_EOC_

no_long_string();

run_tests();

__DATA__

=== TEST 1: atoi
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local str = require "resty.string"
            local pizza  = "piece1 piece2 piece3 piece4 piece5 piece6"
            local pieces, n = str.explode(" ", pizza)
            ngx.say(n)
            ngx.say(pieces[1])
            ngx.say(pieces[6])
            local s = "one|two|three|four"
            local r, n = str.explode("|", s, 2)
            ngx.say(n)
            ngx.say(r[1])
            ngx.say(r[2])
            r, n = str.explode("|", s, -1)
            ngx.say(#r)
            ngx.say(r[3])
            ngx.say(r[4])
            r, n = str.explode("|", s, 0)
            ngx.say(r[1])
        ';
    }
--- request
GET /t
--- response_body
6
piece1
piece6
2
one
two|three|four
3
three
nil
one|two|three|four
--- no_error_log
[error]

