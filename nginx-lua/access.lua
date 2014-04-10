package.path = "/data/nginx/nginx-lua/modules/?.lua;" .. package.path
local token = require("token")
local acl = require("acl")
local authorization = require("authorization")
local error_dto = require("error_dto")
local cjson = require("cjson")

if acl.needs_authorization(ngx.var.uri) then
  authorization.get_grants(cjson, error_dto, ngx.req)
end

token.filter(cjson, error_dto, ngx.var.uri, ngx.req)

