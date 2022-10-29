CREATE OR REPLACE FUNCTION update_user(p_new_username text, p_new_email text, p_current_id text, p_new_password text, p_new_password_repeat text, p_is_password_change boolean)
    RETURNS text
    LANGUAGE plpgsql
AS $function$
declare
    v_result function_result;
begin
    if p_new_username is null then
        return as_result(set_message(v_result, 'Message', 'Creating user with an empty name field is unallowed!', 'ERROR'));
    end if;
    if LENGTH(p_new_username) < 3 then
        return as_result(set_message(v_result, 'Message', 'Username should be longer than 3 elements!', 'ERROR'));
    end if;
    if p_new_email is null then
        return as_result(set_message(v_result, 'Message','Creating user with an empty email field is unallowed!', 'ERROR'));
    end if;
    if p_new_email not like '%@%' then
        return as_result(set_message(v_result, 'Message','User was successfully updated!', 'ERROR'));
    end if;
    if p_new_password is null and p_is_password_change then
        return as_result(set_message(v_result, 'Message', 'Creating user with an empty password field is unallowed!', 'ERROR'));
    end if;
    if p_new_password_repeat is null and p_is_password_change then
        return as_result(set_message(v_result, 'Message','Enter both password fields!', 'ERROR'));
    end if;
    if LENGTH(p_new_password) <= 3 and p_is_password_change then
        return as_result(set_message(v_result, 'Message', 'Password should be longer than 3 elements!', 'ERROR'));
    end if;
    if p_new_password_repeat != p_new_password and p_is_password_change then
        return as_result(set_message(v_result, 'Message', 'Password fields are not equal!', 'ERROR'));
    end if;

    if p_is_password_change then
        update whirl_users
        set
            name = p_new_username,
            email = p_new_email,
            password_hash = crypt(p_new_password, gen_salt('bf'))
        where
            id = p_current_id::int;
    else
        update whirl_users
        set
            name = p_new_username,
            email = p_new_email
        where
            id = p_current_id::int;
    end if;

    return as_result(set_message(v_result, 'Message', 'User was successfully updated!', 'INFO'));
END;
$function$
;
