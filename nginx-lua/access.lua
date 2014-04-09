package.path = "/data/nginx/nginx-lua/modules/?.lua;" .. package.path
local token = require("token")
local acl = require("acl")
local authorization = require("authorization")

if acl.needs_authorization(ngx.var.uri) then
  authorization.get_grants(ngx.req)
end

token.filter(ngx.var.uri, ngx.req)

