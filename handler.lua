local kong = kong
local get_header = kong.request.get_header
local set_header = kong.service.request.set_header
local re_gmatch = ngx.re.gmatch
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local BasePlugin = require "kong.plugins.base_plugin"


local RequestAuthHandler = BasePlugin:extend()
-- PRIORITY
RequestAuthHandler.PRIORITY = 800
RequestAuthHandler.VERSION = "1.0.0"


function RequestAuthHandler:new()
    RequestAuthHandler.super.new(self, "kong_jwt_url_auth")
  end


-- main
function RequestAuthHandler:access(conf)
    RequestAuthHandler.super.access(self)
    -- pass options request
    if kong.request.get_method() == "OPTIONS" then
      return
    end
    local bear_token = get_header("authorization")
    if (bear_token == nil or string.sub(bear_token, 1, 7) ~= "Bearer ") then
        kong.log.inspect("misee bearer")
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end

    local token = string.sub(bear_token, 8, -1)

    -- check
    local jwt, err = jwt_decoder:new(token)
    if err then
      -- return false, { status = 401, message = "Bad token; " .. tostring(err) }
      kong.log.inspect("decode error")
      return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end

    local claims = jwt.claims
    local header = jwt.header

    local secret_key = "1234567891234567891234567891234567891234567"
    if not jwt:verify_signature(secret_key) then
        kong.log.inspect("check secret fail")
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end

    local phone = claims["phone"]
    if phone == nil then
        kong.log.inspect("miss phone in payload")
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end
    kong.log.inspect(phone)
    local user, err = kong.db.login_user:select({ phone = phone })
    if err then
        return error(err)
    end
    if not user then
        kong.log.inspect("login user not found")
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end

    set_header("x-auth-phone", phone)

end


return RequestAuthHandler
