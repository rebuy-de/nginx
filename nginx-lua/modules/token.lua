local token = {}

token.filter = function(filterUri)
  if filterUri == "/oauth/token" then
    if "POST" == ngx.req.get_method() then

      -- setup some app-level vars
      local app_id = "test"
      local app_secret = "test"
      local res = ngx.location.capture("/_access_token?client_id="..app_id.."&client_secret="..app_secret.."&grant_type=password&username=test&password=test&scope=read")
      ngx.say(res.body)
      ngx.exit(ngx.HTTP_OK)
      return 
    end
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end
end

return token
  
