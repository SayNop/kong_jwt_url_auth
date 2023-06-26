local kong = kong
local get_header = kong.request.get_header
local set_header = kong.service.request.set_header
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

    local service_map = { service_a = 0, service_b = 1}
    kong.log.inspect(kong.request.get_forwarded_host())
    kong.log.inspect(kong.request.get_path())
    local service_id = service_map[string.sub(kong.request.get_forwarded_host(), 1, -5)]
    if not service_id then
        kong.log.inspect("service not record")
        return kong.response.exit(404, { code = 404, success = false, data = "", msg = "Not Found" })
    end
    kong.log.inspect(service_id .. kong.request.get_path())
    local api, err = kong.db.api_mgr:select({sign = service_id .. kong.request.get_path()})
    if err then
        return error(err)
    end
    kong.log.inspect(api)
    if not api then
        kong.log.inspect("api not record")
        return kong.response.exit(404, { code = 404, success = false, data = "", msg = "Not Found" })
    end

    local target_level = api.auth_level
    -- local target_level = 0
    -- pass no auth api
    if target_level < 1 then
        return
    end

    local bear_token = get_header("authorization")
    if (bear_token == nil or string.sub(bear_token, 1, 7) ~= "Bearer ") then
        kong.log.inspect("miss bearer")
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

    -- Verify the JWT registered claims
    -- local claims_to_verify = { "exp", "nbf" }
    -- local ok_claims, errors = jwt:verify_registered_claims(claims_to_verify)
    local ok_claims, errors = jwt:verify_registered_claims(conf.claims_to_verify)
    if not ok_claims then
        kong.log.inspect(errors)
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "Token Expired" })
    end

    -- Verify the JWT expiry not too long
    if conf.maximum_expiration ~= nil and conf.maximum_expiration > 0 then
        local ok, errors = jwt:check_maximum_expiration(conf.maximum_expiration)
        if not ok then
            return false, { status = 401, errors = errors }
        end
    end

    local phone = claims["phone"]
    if not phone then
        kong.log.inspect("miss phone in payload")
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end
    kong.log.inspect(phone)

    -- get user model
    local user, err = kong.db.login_user:select({ phone = phone })
    if err then
        return error(err)
    end
    if not user then
        kong.log.inspect("login user not found")
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end

    kong.log.inspect("user level is " .. user.level)
    kong.log.inspect("api level is " .. target_level)
    -- check auth level
    if user.level < target_level then
        kong.log.inspect("Insufficient permissions")
        return kong.response.exit(403, { code = 403, success = false, data = "", msg = "Forbidden" })
    end

    set_header("x-auth-phone", phone)
end


return RequestAuthHandler
