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
          { username = { type = "string", required = true, unique = true }, },
          { password = { type = "string", reference = "consumers", required = true, on_delete = "cascade", }, },
          { level = { type = "number", default = 0 }, },
      },
    },
  }
