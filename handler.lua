-- 	main
local kong = kong
local pcall = pcall

local get_header = kong.request.get_header
local set_header = kong.service.request.set_header
local set_raw_body = kong.service.request.set_raw_body
local ngx_decode_args = ngx.decode_args
local encode_args = ngx.encode_args
local str_find = string.find


local RequestAuthHandler = {}


-- 请求时的处理过程
function local RequestAuthHandler:access(conf)
    local bear_token = get_header("authorization")
    if bear_token == nil then
        return kong.response.exit(401, { code = 20000, data = "", msg = "Missing required parameters" })
    end
end

-- PRIORITY 越大执行顺序越靠前
RequestAuthHandler.PRIORITY = 800
RequestAuthHandler.VERSION = "1.0.0"

return RequestAuthHandler