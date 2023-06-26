# Kong_Jwt_Url_Auth

## Description
A kong plugin that verifies request permissions via JWT token. <br>
Confirm user permissions for each API through the database. 
- Kong Version: 1.1.3
- Postgresql Version: 9.6.24

## File Structure
- handler :  main
- schema :  config
- daos :  cache

## Postgresql Table
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
