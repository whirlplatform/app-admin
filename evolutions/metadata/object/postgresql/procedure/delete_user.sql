CREATE OR REPLACE FUNCTION delete_user(p_field character varying)
    RETURNS character varying
    LANGUAGE plpgsql
AS $function$
declare
    v_result function_result;
    v_api_result row_list;
    v_amount_of_users int := 0;
begin
    v_result.title := 'Result from database';
    v_result.message := p_field;
    v_result.message_type := 'INFO';

    if p_field is null then
        return as_result(set_message(v_result, 'Message', 'Nothing was selected!', 'ERROR'));
    end if;

    v_api_result.list_name := parse_row_list(v_result.message);

    FOR i IN 1 .. array_length(v_api_result.list_name, 1) LOOP
            if v_api_result.list_name[i].selected = 'T' then
                if (SELECT 1 FROM whirl_users where id = v_api_result.list_name[i].id::int) = 1 then
                    v_amount_of_users := v_amount_of_users + 1;
                end if;
                delete from whirl_users where whirl_users.id = v_api_result.list_name[i].id::int;
            end if;
        END LOOP;

    return as_result(set_message(v_result, 'Message', CONCAT('Success! ', array_length(v_api_result.list_name, 1)::text, ' users was selected. ', v_amount_of_users::text, ' users was deleted!'), 'INFO'));
END;
$function$
;
