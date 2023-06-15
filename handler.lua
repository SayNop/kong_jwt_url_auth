-- 	main
local kong = kong
local pcall = pcall
local get_header = kong.request.get_header


local RequestAuthHandler = {}


-- 请求时的处理过程
function local RequestAuthHandler:access(conf)
    local bear_token = get_header("authorization")
    if bear_token == nil then
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end

    if string.sub(sourcestr, 1, 7) ~= "Bearer " then
        return kong.response.exit(401, { code = 401, success = false, data = "", msg = "UnAuthorized" })
    end
    local token = string.sub(bear_token, 8, -1)

end

-- PRIORITY 越大执行顺序越靠前
RequestAuthHandler.PRIORITY = 800
RequestAuthHandler.VERSION = "1.0.0"

return RequestAuthHandler