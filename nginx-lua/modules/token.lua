local token = {}

token.filter = function(filterUri, request)
  if filterUri == "/oauth/token" then
    if "GET" == ngx.req.get_method() then
      local args, err = request.get_uri_args() 

      local res = ngx.location.capture(token.parse(args))
      ngx.say(res.body)
      ngx.exit(ngx.HTTP_OK)
    end

    ngx.exit(ngx.HTTP_FORBIDDEN)
  end
end

token.parse = function(args)
  if not args then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  local status, url = pcall(token.build_url, args)
  if not status then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  return url
end 

token.build_url = function(args)
  local app_id = "test"
  local app_secret = "test"
      
  local url = "/_access_token"
  url = url .. "?client_id=" .. app_id
  url = url .. "&client_secret=" .. app_secret
  url = url .. "&grant_type=" .. args["grant_type"]
  url = url .. "&username=" .. args["username"]
  url = url .. "&password=" .. args["password"]
  url = url .. "&scope=" .. args["scope"]

  return url
end

return token
  
