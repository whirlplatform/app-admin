CREATE OR REPLACE FUNCTION save_user(p_new_login text, p_new_username text, p_new_email text, p_new_password text, p_new_password_repeat text)
    RETURNS text
    LANGUAGE plpgsql
AS $function$
declare
    v_result function_result;
begin
    if p_new_login is null then
        return as_result(set_message(v_result, 'Message', 'Creating user with an empty login field is unallowed!', 'ERROR'));
    end if;
    if LENGTH(p_new_login) < 3 then
        return as_result(set_message(v_result, 'Message', 'Login should be longer than 3 elements!', 'ERROR'));
    end if;
    if p_new_username is null then
        return as_result(set_message(v_result, 'Message', 'Creating user with an empty name field is unallowed!', 'ERROR'));
    end if;
    if LENGTH(p_new_username) < 3 then
        return as_result(set_message(v_result, 'Message', 'Username should be longer than 3 elements!', 'ERROR'));
    end if;
    if p_new_email is null then
        return as_result(set_message(v_result, 'Message', 'Creating user with an empty email field is unallowed!', 'ERROR'));
    end if;
    if p_new_email not like '%@%' then
        return as_result(set_message(v_result, 'Message', 'Enter email in a proper manner!', 'ERROR'));
    end if;
    if p_new_password is null then
        return as_result(set_message(v_result, 'Message', 'Creating user with an empty password field is unallowed!', 'ERROR'));
    end if;
    if p_new_password_repeat is null then
        return as_result(set_message(v_result, 'Message', 'Enter both password fields!', 'ERROR'));
    end if;
    if LENGTH(p_new_password) <= 3 then
        return as_result(set_message(v_result, 'Message', 'Password should be longer than 3 elements!', 'ERROR'));
    end if;
    if p_new_password_repeat != p_new_password then
        return as_result(set_message(v_result, 'Message', 'Password fields are not equal!', 'ERROR'));
    end if;

    if (select exists(select 1
                      from whirl_users wu
                      where
                              wu.login = p_new_login
                   ))
    then
        return as_result(set_message(v_result, 'Message', 'User with this login already exist!', 'ERROR'));
    else
        insert into
            whirl_users(login, name, email, password_hash, creation_date)
        values(
                  p_new_login, p_new_username, p_new_email, crypt(p_new_password, gen_salt('bf')), NOW()
              );
        return as_result(set_message(v_result, 'Message', 'User was successfully created!', 'INFO'));
    end if;
END;
$function$
;
