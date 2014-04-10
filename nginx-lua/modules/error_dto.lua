error_dto = {}

error_dto.create = function(cjson, code, message)
  local dto_object = {}
  dto_object.code = code
  dto_object.message = message
  dto_object.reference = "NginX OAuth2 module"
  
  return cjson.encode(dto_object)
end

return error_dto
