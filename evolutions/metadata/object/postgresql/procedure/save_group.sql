CREATE OR REPLACE FUNCTION save_group(p_field character varying, p_group_code text)
    RETURNS text
    LANGUAGE plpgsql
AS $function$
declare
    v_result function_result;
    v_api_result row_list;
begin
    v_result.title := 'Result from database';
    v_result.message := p_field;
    v_result.message_type := 'INFO';

    if p_field is null then
        return as_result(set_message(v_result, 'Error', 'Nothing was selected!', 'ERROR'));
    end if;
    if p_group_code is null then
        return as_result(set_message(v_result, 'Error', 'Creating group with an empty group code field is unallowed!', 'ERROR'));
    end if;

    v_api_result.list_name := parse_row_list(v_result.message);

    FOR i IN 1 .. array_length(v_api_result.list_name, 1) loop
            insert into
                whirl_user_groups(
                r_whirl_users,
                group_code,
                name
            )
            values(
                  v_api_result.list_name[i].id::int,
                  p_group_code,
                  p_group_code
            );
        END loop;

    if array_length(v_api_result.list_name, 1) = 1 then
        return as_result(
            set_message(
                v_result,
                'Message',
                CONCAT('Group was successfully created!(', array_length(v_api_result.list_name, 1)::text, ')'), 'INFO')
            );
    else
        return as_result(
            set_message(
                v_result,
                'Message',
                CONCAT('Groups were successfully created! (', array_length(v_api_result.list_name, 1)::text, ')'), 'INFO')
            );
    end if;
END;
$function$
;
