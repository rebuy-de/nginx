local acl = {}

acl.needs_authorization = function(filterUri)
  if filterUri == "/oauth/token" then
    return false
  end
  return true
end

return acl;
