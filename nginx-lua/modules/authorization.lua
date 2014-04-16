local authorization = {}

authorization.get_grants = function(cjson, error_dto, request)
  local auth_header = request.get_headers()["Authorization"]
  if auth_header == nil then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end 
  
  local status, auth_token = pcall(authorization.build_auth_request, cjson, auth_header)
  
  if not status then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("[" .. error_dto.create(cjson, "VALIDATION_ERROR", "non valid json format") .. "]")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  if (nil == auth_token.access_token) or (nil == auth_token.token_type) then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end 
 
  local grant_request = authorization.access_confirmation(cjson, request, auth_token)

  if grant_request.status ~= ngx.HTTP_OK then 
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(grant_request.body)
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end
  
  ngx.req.set_header("Authorization", grant)
end

authorization.access_confirmation = function(cjson, request, auth_token)
  local content_header = request.get_headers()["Content-Type"]
  local auth_json = cjson.encode(auth_token)
  
  ngx.req.set_header("Content-Type", "Application/Json")
 
  local ctx = {} 
  local res = ngx.location.capture("/_access_confirmation", {method = ngx.HTTP_POST, body = auth_json, ctx = ctx})

  ngx.req.set_header("Content-Type", content_header)
  
  return res
end

authorization.build_auth_request = function(cjson, auth_header)
  local auth_token_json = cjson.decode(auth_header)
  
  local auth_token = {}
  auth_token.access_token = auth_token_json.access_token
  auth_token.token_type = auth_token_json.token_type
  auth_token.scope = {auth_token_json.scope}     

  return auth_token
end

return authorization;
