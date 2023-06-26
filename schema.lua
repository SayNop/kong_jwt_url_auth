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
                --     -- iss in payload: sign deliver, not check
                --     key_claim_name = { type = "string", default = "iss" },
                -- },
                { maximum_expiration = {
                    -- field description not support on kong 1.x
                    -- description = "maximum_expiration seconds -  31536000 (365 days) / 259200 (3 days)",
                    type = "number",
                    default = 259200,
                    between = { 0, 31536000 },
                  }, 
                },
                {
                    -- array: verify keys in payload
                    claims_to_verify = {
                        -- A list of registered claims (according to RFC 7519) that Kong can verify as well. Accepted values: one of exp or nbf
                        type = "set",

                        elements = {
                            type = "string",
                            one_of = { "exp", "nbf" },
                        }, 
                    }, 
                },
            },
        },
        },
    },
}
