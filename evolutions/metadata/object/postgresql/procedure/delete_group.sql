CREATE OR REPLACE FUNCTION delete_group(p_field character varying)
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

    v_api_result.list_name := parse_row_list(v_result.message);

    FOR i IN 1 .. array_length(v_api_result.list_name, 1) LOOP
            if v_api_result.list_name[i].checked = 'T' then
                delete from
                    whirl_user_groups
                where
                        whirl_user_groups.id = v_api_result.list_name[i].id::int;
            end if;
        END LOOP;

    if array_length(v_api_result.list_name, 1) = 1 then
        return as_result(set_message(v_result, 'Message', CONCAT('Group was successfully deleted! (', array_length(v_api_result.list_name, 1), ')'), 'INFO'));
    end if;
    if array_length(v_api_result.list_name, 1) > 1 then
        return as_result(set_message(v_result, 'Message', CONCAT('Groups were successfully deleted! (', array_length(v_api_result.list_name, 1), ')'), 'INFO'));
    end if;

END;
$function$
;
