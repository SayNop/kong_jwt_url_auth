# Kong_Jwt_Url_Auth

## Description
A kong plugin that verifies request permissions via JWT token. <br>
Confirm user permissions for each API through the database. 
- Kong Version: 1.1.3
- Postgresql Version: 9.6.24

Learn more in my [blog](https://saynop.github.io/detail/008.html).

## Feature
- check token signature
- check token expiry
- check token conflict
- check user has permission to access api


## File Structure
- handler :  main
- schema :  config
- daos :  cache

## Manual
### Config Kong proxy_pass
Use host or path to forward requests
- host route - eg: `service_a.com`, `service_b.com` to different services
    ```bash
    # service
    curl -i -X POST --url http://localhost:8001/services/ --data 'name=service_a' --data 'url=http://0.0.0.0:5001'
    # route
    curl -i -X POST --url http://localhost:8001/services/service_a/routes --data 'name=route_a' --data 'hosts[]=service_a.com'
    # plugin
    curl -X POST http://localhost:8001/services/service_a/plugins -d "name=kong_jwt_url_auth"
    ```

- path route - eg: `example.com/a/*`, `example.com/b/*` to different services
    ```bash
    # service
    curl -i -X POST --url http://localhost:8001/services/ --data 'name=service_a' --data 'url=http://0.0.0.0:5001'
    # route
    curl -i -X POST --url http://localhost:8001/services/service_a/routes --data 'name=route_a' --data 'hosts[]=example.com' --data 'paths[]=/a/'
    # plugin
    curl -X POST http://localhost:8001/services/service_a/plugins -d "name=kong_jwt_url_auth"
    ```


### Replace get service_id in handler.lua
- host route
    ```lua
    local service_map = { ["service_a.com"] = 0, ["service_b.com"] = 1}
    local service_id = service_map[kong.request.get_forwarded_host()]

    local service_map = { ["service_a"] = 0, ["service_b"] = 1}
    local service_id = service_map[string.sub(kong.request.get_forwarded_host(), 1, -5)]
    ```
- path route
    ```lua
    local service_map = { ["/a/"] = 0, ["/b/"] = 1}
    local service_id = service_map[kong.router.get_route().paths[0]]
    ```


### Postgresql Table

- api_mgr :  define api auth level
    ```sql
    CREATE TABLE api_mgr(
        sign VARCHAR(51) PRIMARY KEY,
        path VARCHAR(50) NOT NULL,
        service smallint NOT NULL,
        auth_level smallint DEFAULT 0
    );
    ```

- login_user :  define user and user permissions
    ```sql
    CREATE TABLE login_user(
        phone CHAR(11) PRIMARY KEY NOT NULL,
        username VARCHAR(15) NOT NULL,
        password VARCHAR(15) NOT NULL,
        level smallint DEFAULT 0
    );
    ```

## Notice
Remove all `kong.log.inspect` code in production environment.
