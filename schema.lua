local typedefs = require "kong.db.schema.typedefs"

return {
    name = "kong_jwt_url_auth",  -- plugin name
    fields = {
        { consumer = typedefs.no_consumer },
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            -- conf in handler
            fields = {
                {
                    -- Too long. only support length 32
                    secret_key = { type = "string", default = "1234567891234567891234567891234567891234567" }, 
                },
                -- { 
                --     -- sign deliver, iss, not check
                --     key_claim_name = { type = "string", default = "iss" },
                -- },
            },
        },
        },
    },
}
