local token = {}

token.filter = function(cjson, error_dto, filterUri, request)
  if filterUri == "/oauth/token" then
    if "POST" ~= ngx.req.get_method() then
      ngx.status = ngx.HTTP_FORBIDDEN
      local error_msg = error_dto.create(cjson, "VALIDATION_ERROR", "only post requests supported.")
      ngx.say("[" .. error_msg .. "]")
      ngx.exit(ngx.HTTP_FORBIDDEN)
    end
    
    local head = ngx.req.get_headers()["Content-Type"]
    if (nil == head) or ("application/x-www-form-urlencoded" ~= string.lower(head)) then
      ngx.status = ngx.HTTP_BAD_REQUEST
      local error_msg = error_dto.create(cjson, "VALIDATION_ERROR", "non valid form post. only supported encoding is x-www-form-urlencoding.")
      ngx.say("[" .. error_msg .. "]")
      ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    request.read_body()
    local data = request.get_body_data()
    local body_data = token.build_body(data)

    local res = ngx.location.capture("/_access_token", {method = ngx.HTTP_POST, body = body_data}) 
      
    ngx.say(res.body)
    ngx.exit(ngx.HTTP_OK)
  end
end

token.build_body = function(data)
  if nil == data then
    return data
  end

  local app_id = "test"
  local app_secret = "test"
      
  local body_data = data 
  body_data = body_data .. "&client_id=" .. app_id
  body_data = body_data .. "&client_secret=" .. app_secret

  return body_data
end

return token
  
