-- config
local typedefs = require "kong.db.schema.typedefs"

return {
    name = "request-sign-aes256",  -- plugin name
    fields = {
        { consumer = typedefs.no_consumer },   -- 插件消费者
        { protocols = typedefs.protocols_http },  -- 插件运行的协议
        { config = {
            type = "record",
            fields = {
                { key = { type = "string", default = "12345678912345678912345678912345" }, },
            },
        },
        },
    },
}