local authorization = {}

authorization.cjson = require "cjson"

authorization.get_grants = function(request)
  local auth_header = request.get_headers()["Authorization"]
  if auth_header == nil then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end 
  
  local status, auth_token = pcall(authorization.build_auth_request, auth_header)
  
  if not status then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("[" .. authorization.error_dto("VALIDATION_ERROR", "non valid json format") .. "]")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  if (nil == auth_token.access_token) or (nil == auth_token.token_type) then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end 
 
  local grant = authorization.access_confirmation(request, auth_token)

  if authorization.check_grant_is_error(grant) then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(grant)
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end
  
  ngx.req.set_header("Authorization", grant)
end

authorization.access_confirmation = function(request, auth_token)
  local content_header = request.get_headers()["Content-Type"]
  local auth_json = authorization.cjson.encode(auth_token)
  
  ngx.req.set_header("Content-Type", "Application/Json")
 
  local ctx = {} 
  local res = ngx.location.capture("/_access_confirmation", {method = ngx.HTTP_POST, body = auth_json, ctx = ctx})

  ngx.req.set_header("Content-Type", content_header)
  
  return res.body
end

authorization.build_auth_request = function(auth_header)
  local auth_token_json = authorization.cjson.decode(auth_header)
  
  local auth_token = {}
  auth_token.access_token = auth_token_json.access_token
  auth_token.token_type = auth_token_json.token_type     

  return auth_token
end

authorization.check_grant_is_error = function(grant)
  local dto = authorization.cjson.decode(grant)
  if nil == dto[1] then
    return false
  end
  local keys = authorization.get_table_keys(dto[1])
 
  return keys["code"] and keys["message"] and keys["reference"]
end

authorization.get_table_keys = function(table)
  local key_table = {}
  for key, value in pairs(table) do
    key_table[key] = true
  end

  return key_table
end

authorization.error_dto = function(code, message)
  local dto_object = {}
  dto_object.code = code
  dto_object.message = message
  dto_object.reference = "Authorization Header"
  
  return authorization.cjson.encode(dto_object)
end

return authorization;
