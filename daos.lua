return {
    {
      primary_key = { "phone" },
      name = "login_user",
      endpoint_key = "phone",
      cache_key = { "phone" },
    --   workspaceable = true,
    --   admin_api_name = "kong_jwt_url_auths",
    --   admin_api_nested_name = "kong_jwt_url_auth",
      fields = {
            { phone = { type = "string", required = true, unique = true }, },
            { username = { type = "string", required = true }, },
            { password = { type = "string", required = true}, },
            { level = { type = "number", default = 0 }, },
        },
    },
    {
      primary_key = { "sign" },
      name = "api_mgr",
    --   endpoint_key = "phone",
    --   cache_key = { "phone" },
    --   workspaceable = true,
    --   admin_api_name = "kong_jwt_url_auths",
    --   admin_api_nested_name = "kong_jwt_url_auth",
      fields = {
            { sign = { type = "string", required = true, unique = true }, },
            { path = { type = "string", required = true }, },
            { service = { type = "number", required = true}, },
            { auth_level = { type = "number", default = 0 }, },
        },
    },
}
