CREATE OR REPLACE FUNCTION save_group(p_field character varying, p_group_code text)
    RETURNS text
    LANGUAGE plpgsql
AS $function$
declare
    v_result function_result;
    v_api_result row_list;
    v_count int = 0;
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
            if (select exists(select 1
                              from whirl_user_groups wug
                              where
                                      wug.r_whirl_users = v_api_result.list_name[i].id::int
                                and
                                      p_group_code =  wug.group_code))
            then
                -- do nothing --
            else
                v_count := v_count + 1;
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
            end if;
        END loop;

    if v_count = array_length(v_api_result.list_name, 1) then
        if array_length(v_api_result.list_name, 1) = 1 then
            return as_result(set_message(v_result, 'Message', CONCAT('Group was successfully created!(', v_count::text, ')'), 'INFO'));
        else
            return as_result(set_message(v_result, 'Message', CONCAT('Groups were successfully created! (', v_count::text, ')'), 'INFO'));
        end if;
    else
        if array_length(v_api_result.list_name, 1) = 1 then
            return as_result(set_message(v_result, 'Message', CONCAT('This user already has this group!'), 'INFO'));
        else
            if v_count = 0 then
                return as_result(set_message(v_result, 'Message', CONCAT('All selected users already have these groups!'), 'INFO'));
            else
                return as_result(set_message(v_result, 'Message', CONCAT('Groups were successfully created! (amount of created rows: ', v_count::text, ')', '(some groups was not created because of the dublication)'), 'INFO'));
            end if;
        end if;
    end if;
END;
$function$
;
